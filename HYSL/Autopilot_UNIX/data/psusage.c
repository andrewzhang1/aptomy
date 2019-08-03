/*
	Get Performance Counter

	psusage.exe [-h|-k|-m|-f|-w <waitcnt>|-i|-p|-u <usr>]
compile:
	cl psusage.c Psapi.lib pdh.lib advapi32.lib
	
*/

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <windows.h>
#include <WinBase.h>	// <advapi32.h>
#include <pdh.h>   
#include <psapi.h>  // Psapi.Lib

#define OPEN_PROCESS  (PROCESS_QUERY_INFORMATION | PROCESS_VM_READ)

struct PSREC {
	LPTSTR	name;
	int		nth;
	PDH_HCOUNTER	cpu;
	PDH_HCOUNTER	pid;
	PDH_HCOUNTER	mem;
};

LPTSTR		szInstance;
PDH_HQUERY	hQuery;
struct PSREC	*psRecs;
PDH_HCOUNTER	hTtl;
int		psCnt = 0;
int		dspFmt = 1;	// 0:<instance>#<nth>, 1:<base name>, 2:<Path name>
LPTSTR	usrDef=(LPTSTR)NULL;
int		usrFlg=0; // 0:No dmain name, 1:with Domain name
int		unit = 1, wait = 500;
TCHAR	*unitchr = "B";
TCHAR	*fmt_each = "%d %s %.0f %% %I64u %s %s\n";
TCHAR	*fmt_ttl  = "Total %d process : %.0f / %.0f %% CPU, %ul %s memory.\n";
TCHAR	strwork[32 * 1024];
TCHAR	username[32 * 1024];
TCHAR	tmpbuf[32 * 1024];

int getnthstr(LPTSTR crrwrd);
int cntInstance(LPTSTR str);
void disp_help(void);

int main(int ac, char *av[])
{
	DWORD	dwCounterSize;
	DWORD	dwInstanceSize;
	LPTSTR	lpObject = "Process";
	LPTSTR	lpString;
	SYSTEM_INFO	si;
	PDH_FMT_COUNTERVALUE cpu, pid, mem, ttl;
	int		ret = 0, n, i;
	long	memttl = 0;
	double	total = 0.0;

	// Get system informations.(CPU Count/si.dwNumberOfProcessors)
	GetSystemInfo(&si);

	// Parse parameter.
	for (i = 1; i < ac; ++i) {
		if (strcmp(av[i], "-k") == 0) {
			unit=1024;
			unitchr="KB";
		} else if (strcmp(av[i], "-m") == 0) {
			unit=1024 * 1024;
			unitchr="MB";
		} else if (strcmp(av[i], "-f") == 0) {
			fmt_each = "%d %s %.2f %% %I64u %s %s\n";
			fmt_ttl  = "Total %d process : %.2f / %.2f %% CPU used, %ul %s memory.\n";
		} else if (strcmp(av[i], "-w") == 0) {
			if (i < (ac - 1)) {
				++i;
				wait=atoi(av[i]);
			} else {
				printf("\"-w\" parameter need <msec> counter.\n");
				disp_help();
				return(3);
			}
		} else if (strcmp(av[i], "-h") == 0) {
			disp_help();
			return(0);
		} else if (strcmp(av[i], "-u") == 0) {
			if (i < (ac - 1)) {
				LPTSTR	ptr;
				for (++i, usrFlg = 0, ptr = usrDef = av[i]; *ptr; ++ptr) {
					if (*ptr == '/') {
						usrFlg = 1;
					}
				}
			} else {
				printf("\"-u\" parameter need user name.\n");
				disp_help();
				return(3);
			}
		} else if (strcmp(av[i], "-i") == 0) {
			dspFmt = 0;
		} else if (strcmp(av[i], "-p") == 0) {
			dspFmt = 2;
		} else {
			printf("Parameter error.\n");
			disp_help();
			return(3);
		}
	}
	dwCounterSize=0;
	dwInstanceSize=0;
	PdhEnumObjectItems(NULL, NULL, lpObject,
		NULL, &dwCounterSize,
		NULL, &dwInstanceSize,
		PERF_DETAIL_WIZARD, 0);
	if (szInstance=(LPSTR)LocalAlloc(LPTR, dwInstanceSize)) {
		dwCounterSize=0;		
		PdhEnumObjectItems(NULL, NULL, lpObject,
			NULL, &dwCounterSize,
			szInstance, &dwInstanceSize,
			PERF_DETAIL_WIZARD, 0);
		n = cntInstance(szInstance);
		if (psRecs = (struct PSREC *)LocalAlloc(LPTR, (n + 1) * sizeof(struct PSREC))) {
			if ( PdhOpenQuery(NULL, 0, &hQuery) == ERROR_SUCCESS ){
				for ( psCnt=0, lpString = szInstance ; *lpString != '\0' ; lpString++ ){
					psRecs[psCnt].name = lpString;
					psRecs[psCnt].nth = (n = getnthstr(lpString));
					sprintf(strwork, "\\Process(%s#%d)\\%% Processor Time", lpString, n);
					PdhAddCounter(hQuery, strwork, 0, &(psRecs[psCnt].cpu));
					sprintf(strwork, "\\Process(%s#%d)\\ID Process", lpString, n);
					PdhAddCounter(hQuery, strwork, 0, &(psRecs[psCnt].pid));
					sprintf(strwork, "\\Process(%s#%d)\\Working Set Peak", lpString, n);
					PdhAddCounter(hQuery, strwork, 0, &(psRecs[psCnt].mem));
					lpString += lstrlen(lpString);
					++psCnt;
				}
				PdhAddCounter(hQuery, "\\Processor(_Total)\\% Processor Time", 0, &hTtl);
					
				PdhCollectQueryData(hQuery);
				Sleep(wait);
				PdhCollectQueryData(hQuery);
	
				for (i = 0; i < psCnt; ++i) {
					PdhGetFormattedCounterValue(psRecs[i].cpu, PDH_FMT_DOUBLE, NULL, &cpu);
					PdhGetFormattedCounterValue(psRecs[i].pid, PDH_FMT_LONG, NULL, &pid);
					PdhGetFormattedCounterValue(psRecs[i].mem, PDH_FMT_LARGE, NULL, &mem);
					if (pid.longValue) {
						HANDLE hProcess;
						HMODULE Module[ 1024 ] = { 0 };
						DWORD	dwSize, dwSizeName, dwSizeDomain;
						PTOKEN_USER pTokenUser;
						HANDLE      hToken;
						SID_NAME_USE sidName;
						DWORD       dwLength;
						int			trgflg; // Target flag 1:yes, 0:not target

						sprintf(strwork, "%s#%d", psRecs[i].name, psRecs[i].nth); // Make default display name
						username[0] = 0;
						tmpbuf[0] = 0;
						if (hProcess = OpenProcess(OPEN_PROCESS, FALSE, pid.longValue)) {
							if (dspFmt && EnumProcessModules(hProcess, Module, sizeof(Module), &dwSize)) {
								if (dspFmt == 1) { // Base name
									GetModuleBaseName(hProcess, Module[0], strwork, sizeof(strwork));
								} else if (dspFmt == 2) { // Path name
									LPTSTR	ptr;
									GetModuleFileNameEx(hProcess, Module[0], strwork, sizeof(strwork));
									for (ptr = strwork; *ptr; ++ptr) {
										if (*ptr == 0x5c)
											*ptr = '/';
									}
								}
							}
							if (OpenProcessToken(hProcess, TOKEN_QUERY, &hToken)) {
								GetTokenInformation(hToken, TokenUser, NULL, 0, &dwLength);
								pTokenUser = (PTOKEN_USER)LocalAlloc(LPTR, dwLength);
								GetTokenInformation(hToken, TokenUser, pTokenUser, dwLength, &dwLength);
								dwSizeName=sizeof(tmpbuf) / sizeof(TCHAR);
								dwSizeDomain=sizeof(username) / sizeof(TCHAR);
								LookupAccountSid(NULL, pTokenUser->User.Sid,
									tmpbuf, &dwSizeName, 
									username, &dwSizeDomain, &sidName);
								if (!strcmp(username, "NT AUTHORITY")) {
									strcpy(username, tmpbuf);
								} else {
									strcat(username, "/");
									strcat(username, tmpbuf);
								}
								LocalFree(pTokenUser);
								CloseHandle(hToken);
							} // End of OpenProcess
							CloseHandle( hProcess );
						}
						trgflg = usrDef ?
								( usrFlg ? (strcmp(username, usrDef) ? 0 : 1)
										 : (strcmp(tmpbuf, usrDef) ? 0 : 1)
								) : 1;
						if (trgflg) {
							printf(fmt_each, 
								pid.longValue, strwork, 
								cpu.doubleValue / si.dwNumberOfProcessors,
								mem.largeValue / unit, unitchr, username);
								total += cpu.doubleValue;
								memttl += mem.largeValue;
   						}
					}
				} // Next
				PdhGetFormattedCounterValue(hTtl, PDH_FMT_DOUBLE, NULL, &ttl);
				printf(fmt_ttl, psCnt, 
					total / si.dwNumberOfProcessors, ttl.doubleValue, 
					memttl / unit, unitchr);
				PdhCloseQuery(hQuery);
			} else {
				printf("PdhOpenQuery() failed.\n");
				ret = 1;
			}
			LocalFree(psRecs);
		} else {
			printf("LocalAlloc() for psRecs failed.\n");
			ret = 2;
		}
	} else {
		printf("LocalAlloc() for szInstance failed.\n");
		ret = 2;
	}
	return(ret);
}

void disp_help(void)
{
	printf("Display CPU and Memory usage tool 1.01.\n");
	printf("This command display the Process information like below format:\n");
	printf("<pid> <module-name> <CPU%%> <mem#> B|KB|MB <User name>\n");
	printf("psusage.exe [-h|-i|-p|-k|-w <msec>|-u <usr>]\n");
	printf(" -h       : Display this document.\n");
	printf(" -i       : Display instance and index number for <module-name>.\n");
	printf(" -p       : Display full path name for <module-name>.\n");
	printf(" -k       : Display memory size in KB unit.\n");
	printf(" -m       : Display memory size in MB unit.\n");
	printf(" -f       : Display CPU percentage with 2 digit floating point value.\n");
	printf(" -w <msec>: Wait duration in miliseconds (1000=1 sec. Default=500).\n");
	printf(" -p <usr> : Display the tasks for <usr>.\n");
}

int getnthstr(LPTSTR crrwrd)
{
	LPTSTR	lptr=szInstance;
	int		nth;
	
	for(nth = 0, lptr=szInstance; *lptr != '\0' && lptr < crrwrd; lptr++) {
		 if (lstrcmp(lptr, crrwrd) == 0) {
		 	 ++nth;
		 }
		 lptr += lstrlen(lptr);
	}
	return(nth);
}

int cntInstance(LPTSTR str)
{
	int cnt;
	
	for (cnt = 0; *str != '\0'; str++){
		
		str += lstrlen(str);
		++cnt;
	}
	return(cnt);
}
