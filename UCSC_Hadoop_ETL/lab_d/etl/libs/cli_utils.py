#!/usr/bin/python3
"""
Etl utils contains the basic utility functions used to build jobs.

Version : 1.12

"""
from __future__ import print_function
import os
import shlex
import sys
import json
import subprocess
from subprocess import PIPE, Popen
from datetime import date, timedelta, datetime
import docopt


DATE_MACROS = {'yesterday': -1, 'today': 0}
EXIT_CODE_SUCCESS = 0
EXIT_CODE_FAILURE = 1
DEBUG_MODE = True


class AppError(Exception):
    """Base class to all user level exceptions"""
    pass


def add_to_path(the_path):
    """
    Adds the path to the OS Path environment
    :param the_path: The path to be added to list of paths.
    """
    if the_path not in sys.path:
        sys.path.insert(0, the_path)


def write_info(message):
    """
    Write information line to console.
    :param message: The message to be printed. (Do not include line feed).
    """
    sys.stderr.write('[INFO] {0}\n'.format(message))
    sys.stderr.flush()


def write_info_long_line(message):
    """
    Write information line to console.
    :param message: The message to be printed. (Do not include line feed).
    """

    sys.stderr.write('[INFO] {0}'.format(message))
    sys.stderr.flush()


def write_error(message):
    """
    Write error line to console.
    :param message: The message to be printed. (Do not include line feed).
    """
    sys.stderr.write('[ERROR] {0}'.format(message))
    sys.stderr.flush()


def write_plain(message):
    """
    Write plain line to console.
    :param message: The message to be printed. (Do not include line feed).
    """
    sys.stderr.write(message)
    sys.stderr.flush()


def read_txt_file(file_name):
    """
    Loads the contents of file and returns it as a list.
    :param file_name: file name including path of the file.
    """
    with open(file_name, 'r') as handle:
        lines = handle.readlines()
    return [x.strip('\n') for x in lines]


def write_txt_file(file_name, data):
    """
    Writes data into a text file.
    :param data: The data to be written. If list adds line feeds.
    :param file_name: the filename including path.
    """
    # pylint: disable=unidiomatic-typecheck
    with open(file_name, 'w') as handle:
        if type(data) is list:
            handle.write('\n'.join(data))
        else:
            handle.write(data)


def evaluate_date(dt_date, current_date=date.today()):
    """
    Parses date macros converting Yesterday into a real date.
    :param dt_date: The date to convert.
    :param current_date: The current data so we can calculate yesterday,
    """
    date_str = dt_date.lower()
    if date_str in DATE_MACROS:
        delta_days = DATE_MACROS[date_str]
        new_date = current_date + timedelta(days=delta_days)
        return new_date.strftime('%Y-%m-%d')
    return dt_date


def evaluate_relative_date(dt_date, off_set):
    """Calculates dates relatives to a date."""
    ref_date = datetime.strptime(dt_date, "%Y-%m-%d")
    new_date = ref_date + timedelta(days=off_set)
    return new_date.strftime('%Y-%m-%d')


def execute_shell_command(command, debug=False, silent=False):
    """
    Executes a shell command.
    :param command: Command to be executed.
    :param debug: If true just prints the command.
    :param silent: If true does not show any message and return failure.

    """
    # pylint: disable=broad-except

    try:
        write_info(command + '\n')
        cmd_list = shlex.split(command)
        if debug:
            write_plain('> ' + command + '\n')
            return [], EXIT_CODE_SUCCESS
        if silent:
            devnull = open(os.devnull, 'wb')
            child = Popen(cmd_list, stdout=PIPE, stderr=devnull)
        else:
            child = Popen(cmd_list, stdout=PIPE)
        results = child.communicate()[0]
        results = results.decode('utf8')
        code = child.returncode
        return results.split("\n"), code
    except subprocess.CalledProcessError as error:
        if not silent:
            print(error)
        return [], error.returncode
    except Exception as error:
        if not silent:
            print(error)
    return [], EXIT_CODE_FAILURE


def get_this_file_path(file_location):
    """
    Returns the directory where the file is located.
    :param file_location: The path to be converted in absolute path
    """
    return os.path.abspath(os.path.dirname(os.path.abspath(file_location)))


def docopt_parse(docopt_tpl, version):
    """
    Parses the command line args using docopts definition.
    :param docopt_tpl: String template to parsed and submitted to docopt.
    :param version: The string containing the app version to be included on
                    the doc.
    """
    program_name = os.path.basename(sys.argv[0])
    command_doc = docopt_tpl.format(program_name=program_name, version=version)
    arguments = docopt.docopt(command_doc)
    return command_doc, arguments


def print_docopt_error(command_doc, error_msg):
    """
    Prints formatted docopt definition and message
    :param command_doc: The docopt string.
    :param error_msg: The error message.
    """
    print(command_doc.strip('\n'))
    print('')
    write_error(error_msg)


def verify_args_against_docopt(command_doc, optional_commands, arguments):
    """Verify if required options are provided per docopts.
    :param command_doc: Docopt string.
    :param optional_commands: list of optional commands.
    :param arguments: Command line args in a dictionary.
    """
    parts = command_doc.split("\n")
    for part in parts:
        line = part.strip()
        if line.startswith('--'):
            option_expression = line.split(' ')[0]  # Removes the comments.
            command_and_value = option_expression.split('=')
            command = command_and_value.pop(0)
            if (command not in optional_commands and
                    arguments[command] is None):
                return False, 'Missing option {0}'.format(command)
    # If got here the parameter required are present.
    return True, None


def load_json_configuration(file_name):
    """
    Load json configuration file.
    :param file_name: Text file to be loaded as json.
    """
    with open(file_name) as file_handle:
        data = json.loads(file_handle.read())
    return data


def execute_cmd(cmd, dry_run=False):
    """
    Execute bash command

    Parameters
    ----------
    cmd: string representing the command.
    dry_run: If True just prints the command instead of running it.
    """
    if dry_run:
        write_plain('> ' + cmd + '\n')
        error_code = EXIT_CODE_SUCCESS
    else:
        _, error_code = execute_shell_command(cmd)
    if error_code != EXIT_CODE_SUCCESS:
        write_info('Code={0}, {1}\n'.format(error_code, cmd))
    return error_code == EXIT_CODE_SUCCESS


def adjust_indent_data(data):
    """
    Adjust indent text to save to bash files.
    :param data: An array of strings to be adjusted.
    """

    def find_indent(line_str):
        """Finds the indent for the string."""
        return max(0, len(line_str) - len(line_str.lstrip()))

    if len(data) < 2:
        return data
    result = []
    ref_indent = find_indent(data[0])
    if ref_indent == 0:
        ref_indent = find_indent(data[1])
    for idx, line in enumerate(data):
        if idx == 0:
            continue
        current_indent = find_indent(line)
        if ref_indent <= current_indent:
            result.append(line[ref_indent:])
        else:
            result.append(line[current_indent:])
    return result


def current_time():
    """Return the current time to calculate elapsed times."""
    return datetime.now().replace(microsecond=0)
