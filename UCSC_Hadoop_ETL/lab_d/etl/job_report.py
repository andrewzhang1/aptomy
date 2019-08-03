#!/usr/bin/env python3.4
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
  job_report.py run --cfg_file=CF [--dt_date=DT]
  job_report.py dry_run --cfg_file=file [--dt_date=DT]


Options:
  -h --help                Shows this help.
  -c --cfg_file=CF         Defines the configuration file to be used.
  --dt_date=DT             Date to be processed.

Commands:
  run                      Runs the etl calling the programs.
  dry_run                  Shows the code to be executed.

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
LOCAL_DIR = '/shared/lab_d/data/data_nasa/'

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
        config_file = os.path.join(self.script_dir, CFG_DIR,
                                   self.arguments['--cfg_file'])
        self.config = json.load(open(config_file))
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

    def step_01_counts_per_day(self):
        """Execute step 02"""
        ctx = dict()
        ctx['dt_date'] = self.get_date()
        write_info('xxxxx - [dt={0}]'.format(ctx['dt_date']))
        cmd_tpl = """
         
          ;
        """
        results, code = hive_query_template(cmd_tpl, ctx)
        write_plain('Results\n')
        for line in results:
            write_plain(line + '\n')
        write_plain('-------\n')
        return results, code

    def step_02_counts_per_day_type(self):
        """Execute step 02"""
        ctx = dict()
        ctx['dt_date'] = self.get_date()
        write_info('xxxxx - [dt={0}]'.format(ctx['dt_date']))
        cmd_tpl = """

          ;
        """
        results, code = hive_query_template(cmd_tpl, ctx)
        write_plain('Results\n')
        for line in results:
            write_plain(line + '\n')
        write_plain('-------\n')
        return results, code

    def step_03_avg_size_per_day_type(self):
        """Execute step 02"""
        ctx = dict()
        ctx['dt_date'] = self.get_date()
        write_info('xxxxx - [dt={0}]'.format(ctx['dt_date']))
        cmd_tpl = """

          ;
        """
        results, code = hive_query_template(cmd_tpl, ctx)
        write_plain('Results\n')
        for line in results:
            write_plain(line + '\n')
        write_plain('-------\n')
        return results, code

    def execute_etl(self):
        """Execute the etl steps and handle dry_runs."""
        _, code = self.step_01_counts_per_day()
        if code != EXIT_CODE_SUCCESS:
            return code
        _, code = self.step_02_counts_per_day_type()
        if code != EXIT_CODE_SUCCESS:
            return code
        _, code = self.step_03_avg_size_per_day_type()
        if code != EXIT_CODE_SUCCESS:
            return code
        # Always return the error code.
        return code

    def execute(self):
        """Controls the execution of steps and populating exit code."""
        if self.arguments['run'] or self.arguments['dry_run']:
            exit_code = self.execute_etl()
        else:
            exit_code = EXIT_CODE_FAILURE
        if exit_code != EXIT_CODE_SUCCESS:
            write_info('Job Failed!')
        return exit_code


if __name__ == '__main__':
    sys.exit(ETLNasaJob().execute())
