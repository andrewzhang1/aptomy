import sys, string, os
filename=sys.argv[1]
#filename="agz1117@hotmail.com__DataCollection_2015-03-08_230047_Result.txt"
email_addr=filename.split("__")[0]
from sendattach_0310 import mail
mail(email_addr,"Your cycling results by Aptomy", "Your results are in the attached pdf report. Cheers! - Aptomy Server",filename)
print filename
exit()

