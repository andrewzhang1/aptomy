#!/home/azhang/anaconda3/bin/python
"""
ETL Job Basic - ETL job driver basic template script.
Version : {version}

Description:
    This program allows developers to create script in a monolithic form
    and add "markup" language to define each step.

    It has 3 commands:
        run             -> Runs the job step by step.
        dry_run         -> Print the commands to be executed in sequence.


Usage:
  job_nasa.py run --cfg_file=CF [--dt_date=DT]
  job_nasa.py dry_run --cfg_file=file [--dt_date=DT]
  job_nasa.py describe


Options:
  -h --help                Shows this help.
  -c --cfg_file=CF         Defines the configuration file to be used.
  --dt_date=DT             Date to be processed.

Commands:
  run                      Runs the etl calling the programs.
  dry_run                  Shows the code to be executed.
  describe                 Describe the job steps.

Examples:

  python -m etl.job_basic dry_run --cfg_file='test.json'

  To execute the etl dry run.

"""
from __future__ import print_function
import os
import sys
import collections
import json
import time
# import tempfile
#  from pprint import pprint
from datetime import datetime
from libs.cli_utils import docopt_parse, evaluate_date
from libs.cli_utils import EXIT_CODE_FAILURE, EXIT_CODE_SUCCESS
from libs.cli_utils import add_to_path, write_plain, write_info
from libs.cli_utils import get_this_file_path, execute_shell_command
from libs.hive_utils import resolve_template, hive_query_template

# General constants
PROG_VERSION = '1.0.1'
CFG_DIR = 'etc'
# Log Prefixes
INFO = "INFO"
ERROR = "ERROR"
WARN = "WARN"
EXEC = "EXEC"
LOCAL_DIR = '/mnt/AGZ1/Hortonworks_home/azhang/UCSC_Hadoop_ETL/lab_d/data/data_nasa/'

# Records used to build sequence of steps.
EtlStep = collections.namedtuple('EtlStep', 'name start_time end_time')


class ETLNasaJob(object):
    """Basic ETL Job."""

    def __init__(self):
        self.script_dir = get_this_file_path(__file__)
        add_to_path(self.script_dir)
        self.command_doc, self.arguments = docopt_parse(__doc__, PROG_VERSION)
        # self.work_dir = None
        time_stamp = time.time()
        self.time_stamp = datetime.fromtimestamp(time_stamp).strftime(
            '%Y-%m-%d %H:%M:%S')
        self.config = None
        self.etl_prefix_name = 'Nasa ETL'
        self.dry_run = self.arguments.get('dry_run', False)

    def get_date(self):
        """Capture the date from command line"""
        the_date = self.arguments.get('--dt_date', None)
        if not the_date:
            the_date = 'today'
        return evaluate_date(the_date)

    def get_staging_dir_for_date(self):
        """Capture the date from command line"""
        the_date = self.arguments.get('--dt_date', None)
        if not the_date:
            the_date = 'today'
        temp_load = self.get_temp_root_path()
        return temp_load + '/' + evaluate_date(the_date)

    def get_temp_root_path(self):
        """Returns the root location for the base of staging area."""
        return self.config['hdfs_locations']['temp_load']

    def make_job_title(self, suffix_str):
        """Returns a name of the step to appear on Hadoop logs."""
        return self.etl_prefix_name + ' ' + suffix_str

    def _exec_command(self, cmd_tpl, ctx, force_dry_run=None):
        """Execute the command with support for dry run."""
        if force_dry_run:
            dry_run = True
        else:
            dry_run = self.dry_run
        commands = resolve_template(cmd_tpl, ctx)
        if dry_run:
            results, code = '', EXIT_CODE_SUCCESS
        else:
            results, code = execute_shell_command(commands)
        return results, code

    def step_01_prepare_input_dir(self):
        """Execute step 01 - Prepare input dir."""
        ctx = dict()
        write_info('List hdfs input dir')
        ctx['hdfs_temp_load'] = self.get_temp_root_path()
        cmd_tpl = "hdfs dfs -ls {{ctx.hdfs_temp_load}}"
        results, code = self._exec_command(cmd_tpl, ctx)
        if code != EXIT_CODE_SUCCESS:
            return None, code
        write_plain('--- Input location in hdfs ---\n')
        for line in results:
            write_plain(line + '\n')

        # create base dir if does not exists.
        target_hdfs_dir = self.get_staging_dir_for_date()
        write_info('Creating the dir {0}'.format(target_hdfs_dir))
        ctx = dict()
        ctx['hdfs_path'] = target_hdfs_dir
        cmd_tpl = "hdfs dfs -mkdir -p {{ctx.hdfs_path}}/"
        results, code = self._exec_command(cmd_tpl, ctx)
        return None, code

    def step_02_load_hdfs_file(self):
        """Execute step 02 - Loads the file"""
        ctx = dict()
        local_file = LOCAL_DIR + '/nasa_' + self.get_date()
        target_hdfs_dir = self.get_staging_dir_for_date()
        write_info('Loading the file {0}'.format(local_file))
        ctx['local_file'] = local_file
        ctx['hdfs_path'] = target_hdfs_dir
        cmd_tpl = "hdfs dfs -put -f {{ctx.local_file}} {{ctx.hdfs_path}}/"
        results, code = self._exec_command(cmd_tpl, ctx)
        return results, code

    def step_03_update_load_table(self):
        """Execute step 02"""
        ctx = dict()
        ctx['dt_date'] = self.get_date()
        ctx['hdfs_path'] = self.get_staging_dir_for_date()
        write_info('Show partitions - [dt={0}]'.format(ctx['dt_date']))
        cmd_tpl = """
          DROP TABLE IF EXISTS nasa_raw_2;
          CREATE EXTERNAL TABLE nasa_raw_2 (
            FLD_1 STRING,   
            GET_URL STRING,  
            FLD_2 STRING)
          ROW FORMAT DELIMITED
          FIELDS TERMINATED BY "\\""
          LOCATION "{{ctx.hdfs_path}}"
          ;
        """
        results, code = hive_query_template(cmd_tpl, ctx)
        write_plain('Results\n')
        for line in results:
            write_plain(line + '\n')
        write_plain('-------\n')
        return results, code

    def step_04_show_current_partitions(self):
        """Execute step 04"""
        ctx = dict()
        ctx['dt_date'] = self.get_date()
        write_info('Show partitions')
        ctx['hdfs_temp_load'] = self.config['hdfs_locations']['temp_load']
        cmd_tpl = """
            SHOW PARTITIONS nasa_daily;
        """
        results, code = hive_query_template(cmd_tpl, ctx)
        write_plain('Partitions:\n')
        for line in results:
            write_plain(line + '\n')
        write_plain('-----------------------\n')
        return results, code

    def step_05_load_into_nasa_daily(self):
        """Execute step 04"""
        ctx = dict()
        ctx['dt_date'] = self.get_date()
        ctx['job_name'] = 'Insert data into nasa_daily'
        write_info('Show partitions')
        cmd_tpl = """
          SET mapred.job.name={{ctx.job_name}};
          
          INSERT OVERWRITE TABLE nasa_daily 
          PARTITION(dt_date = "{{ctx.dt_date}}") 
            SELECT 
              regexp_extract(FLD_1, '(.*?) (.*?)', 1) as ip_address,
              regexp_extract(FLD_1, '(.*?)\\\\[(.*?) ', 2) as request_time,
              regexp_extract(GET_URL, 'GET (.*?) (.*?)', 1) as page_url,
              regexp_extract(FLD_2, '([0-9].*) ([0-9].*)', 1) as error_code,
              regexp_extract(FLD_2, '([0-9].*) ([0-9].*)', 2) as page_size
            FROM nasa_raw_2
            ;
        """
        results, code = hive_query_template(cmd_tpl, ctx)
        return results, code

    def execute_etl(self):
        """Execute the etl steps and handle dry_runs."""
        _, code = self.step_01_prepare_input_dir()
        if code != EXIT_CODE_SUCCESS:
            return code
        _, code = self.step_02_load_hdfs_file()
        if code != EXIT_CODE_SUCCESS:
            return code
        _, code = self.step_03_update_load_table()
        if code != EXIT_CODE_SUCCESS:
            return code
        _, code = self.step_04_show_current_partitions()
        if code != EXIT_CODE_SUCCESS:
            return code
        _, code = self.step_05_load_into_nasa_daily()
        if code != EXIT_CODE_SUCCESS:
            return code
        # Always return the error code.
        return code

    def describe_steps(self):
        """Just list the steps about the ETL."""
        write_plain("Job Steps {0} \n\n".format(self.etl_prefix_name))
        write_plain("\t01 - Prepare stating dir \n")
        write_plain("\t02 - Load hdfs file \n")
        write_plain("\t03 - Update stage table to point to new dir\n")
        write_plain("\t04 - Show partitions nasa_daily\n")
        write_plain("\t05 - Insert data into nasa_daily table\n")
        write_plain("\nEnd \n")
        return EXIT_CODE_SUCCESS

    def execute(self):
        """Controls the execution of steps and populating exit code."""
        if self.arguments['run'] or self.arguments['dry_run']:
            config_file = os.path.join(self.script_dir, CFG_DIR,
                                       self.arguments['--cfg_file'])
            self.config = json.load(open(config_file))
            exit_code = self.execute_etl()
        elif self.arguments['describe']:
            exit_code = self.describe_steps()
        else:
            exit_code = EXIT_CODE_FAILURE
        if exit_code != EXIT_CODE_SUCCESS:
            write_info('Job Failed!')
        return exit_code


if __name__ == '__main__':
    sys.exit(ETLNasaJob().execute())
