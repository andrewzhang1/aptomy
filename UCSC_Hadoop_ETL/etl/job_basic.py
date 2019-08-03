#!/usr/bin/env python
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
  job_basic.py run --cfg_file=CF [--dt_date=DT]
  job_basic.py dry_run --cfg_file=file [--dt_date=DT]


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
from libs.cli_utils import docopt_parse, evaluate_date, evaluate_relative_date
from libs.cli_utils import EXIT_CODE_FAILURE, EXIT_CODE_SUCCESS
from libs.cli_utils import add_to_path  # ,write_error, write_info
from libs.cli_utils import get_this_file_path, execute_shell_command
from libs.hive_utils import resolve_template

# General constants
PROG_VERSION = '1.0.1'
CFG_DIR = 'etc'
# Log Prefixes
INFO = "INFO"
ERROR = "ERROR"
WARN = "WARN"
EXEC = "EXEC"

# Records used to build sequence of steps.
EtlStep = collections.namedtuple('EtlStep', 'name start_time end_time')


class ETLBasicJob(object):
    """Basic ETL Job."""

    def __init__(self):
        self.script_dir = get_this_file_path(__file__)
        add_to_path(self.script_dir)
        self.command_doc, self.arguments = docopt_parse(__doc__, PROG_VERSION)
        self.work_dir = None
        time_stamp = time.time()
        self.time_stamp = datetime.fromtimestamp(time_stamp).strftime(
            '%Y-%m-%d %H:%M:%S')
        self.config = None

    def execute_step_01(self, dry_run):
        """Execute step 01"""

        config_file = os.path.join(self.script_dir, CFG_DIR,
                                   self.arguments['--cfg_file'])
        self.config = json.load(open(config_file))
        context = dict()
        the_date = self.arguments.get('--dt_date', None)
        if not the_date:
            the_date = 'today'
        context['dt_date'] = evaluate_date(the_date)
        context['dt_minus_30'] = evaluate_relative_date(
            context['dt_date'], -30)
        context['program_name'] = 'ETL Sample run for: {0}'.format(
            context['dt_date'])
        db_name = self.config['db_def']['database']
        tb_name = self.config['db_def']['table']
        context['dir'] = str("/data/" + db_name + "/" + tb_name)
        cmd_tpl = """
            hdfs dfs -rm {{ctx.dir}}/dt='{{ctx.dt_minus_30}}';
            hdfs dfs -mv /data/new {{ctx.dir}}/dt='{{ctx.dt_date}}';
        """
        commands = resolve_template(cmd_tpl, context)
        if dry_run:
            print(commands)
            results, code = '', EXIT_CODE_SUCCESS
        else:
            results, code = execute_shell_command(commands)
        return results, code

    def execute_etl(self, dry_run=False):
        """Execute the etl steps and handle dry_runs."""
        results, code = self.execute_step_01(dry_run)
        return code

    def execute(self):
        """Controls the execution of steps and populating exit code."""
        if self.arguments['run']:
            exit_code = self.execute_etl(False)
        elif self.arguments['dry_run']:
            exit_code = self.execute_etl(True)
        else:
            exit_code = EXIT_CODE_FAILURE
        return exit_code


if __name__ == '__main__':
    sys.exit(ETLBasicJob().execute())
