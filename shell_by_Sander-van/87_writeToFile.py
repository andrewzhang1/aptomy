import sys
count = len(sys.argv)
name = ''

if (count == 1):
    name = input("Give a name: ")
else:
    name = sys.argv[1]

print ("Name is: " + name)

log = open("/mnt/AGZ1/GD_AGZ1117/AGZ_Home/workspace_pOD/shell_by_Sander-van/file.log", "a")
log.write("Hello " + name + "\n")
log.close()

