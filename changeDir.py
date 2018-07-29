import os, subprocess

filename="stats.html"
for root, dirs, files in os.walk(".", topdown=False):
        if filename in files:
           
           pathlocation = os.path.join(root, filename)
           #note: subprocess,check_output is available in python 2.7
           #IP = subprocess.check_output("cat " +path+ " | awk '{print NF}'", shell=True)
           ipTMP = subprocess.Popen(["cat " + pathlocation + " | grep -iE 'esx host' | awk '{print $NF}'"],stdout=subprocess.PIPE, shell=True)
           IP = ipTMP.communicate()[0]
           IP=IP[:-1]

           #current directory name
           path,foldername = os.path.split(os.path.dirname(pathlocation))
           
           if "-vsan-" not in foldername:
             newdir = os.path.dirname(pathlocation) + "-vsan-" + IP
             currentdir = os.path.dirname(pathlocation)

             #rename directory
             print "Rename directory: " + currentdir + "-----> " + newdir
             try:
               os.rename(currentdir, newdir)
             except Exception as e:
               print "unable to rename directory"
