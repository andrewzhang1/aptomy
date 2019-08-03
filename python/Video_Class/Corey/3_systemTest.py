import os, glob
#os.chdir(("/mnt/AGZ1/GD_AGZ1117/AGZ_Home/workspace_pOD/1_HouseKeeper/Corey"))
os.chdir(("C:\\AGZ1\\aptomy\\Video_Class\\Corey"))

for file in glob.glob("*.py"):
    print(file)
