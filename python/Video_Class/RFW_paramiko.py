import paramiko  # connnect from client to server using sshv2
import base64
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(hostname='192.168.133.143',username='azhang',password='password',port=22)
stdin, stdout, stdrr = ssh.exec_command('pwd; ls')
print("the outpu is: ")
print(stdout.readlines())

#encode = base64.b32encode("test")

#print(encoded)

# https://github.com/paramiko/paramiko/
# key = paramiko.cd (data=base64.b64decode(b'AAA...'))
# client = paramiko.SSHClient()
# client.get_host_keys().add('ssh.192.168.133.143', 'ssh-rsa', key)
# client.connect('ssh.192.168.133.143', username='azhang', password='password')
# stdin, stdout, stderr = client.exec_command('ls')
# for line in stdout:
#     print('... ' + line.strip('\n'))
# client.close()