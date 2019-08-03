ETL Nasa
========

1. This project small ETL for the nasa data.
--------------------------------------------

It contains the libraries and a nasa job script showing how to
organize code to run ETLs in production.

For more information run:

cd /shared/lab_d/etl
# to get help
./job_nasa.py --help

# run etl for one day.
./job_nasa.py run --cfg_file=config.json --dt_date=1995-07-01


2. Build the jar for user defined function UDF.
-----------------------------------------------

cd /shared/lab_d/udfs/grid-udfs
./build_jar.sh

# The final jar is available at
cd /shared/lab_d/jars
ls -la
-rw-r--r-- 1 cloudera cloudera 87210518 Apr  3 00:00 grid.udf-1.0.0-fat.jar

3. Check the UDF we've created.
------------------------------

type 'hive'
> ADD JAR /shared/lab_d/jars/grid.udf-1.0.0-fat.jar; 
> CREATE TEMPORARY FUNCTION year_date AS 'edu.ucsc.grid.udf.DateYear';
> describe function extended year_date;


4. Execute a script using the function.
---------------------------------------

cd /shared/lab_d/udf_example
./udf_test.sh

5. Install the python3.4 on CDH5.13
-----------------------------------

sudo yum install python34
sudo yum install python34-setuptools
sudo easy_install-3.4 pip
sudo python3.4 -m pip install jinja2
sudo python3.4 -m pip install docopt

Note: DO NOT EXECUTE 'yum update', it will break cloudera environment.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



