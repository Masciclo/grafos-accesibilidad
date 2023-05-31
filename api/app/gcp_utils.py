import logging
import subprocess
import os

def exec_shell_command(command):
    """
    Execute shell command and return output as a string
    :param command:  1D array of strings e.g. ['ls', '-l']
    :return: output of command
    """
    logging.info(command)
    process = subprocess.run(command, stdout=subprocess.PIPE, universal_newlines=True)
    return process.stdout, process.returncode

def run_query(query, query_name=''):
    print("Running query", query_name)
    output, _ = exec_shell_command([
        'bq', 'query', 
        '--use_legacy_sql=false',
        query
    ])
    print(output)
    



def check_if_file_exists_storage(storage_source):
    _, return_code = exec_shell_command([
        'gsutil', '-q', 'stat', storage_source
    ])
    return return_code


def export_to_storage(table_path, storage_destination):
    print("Exporting indicator in", table_path)
    output, _ = exec_shell_command([
        'bq', 'extract', '--destination_format', 'CSV',
        '--print_header=false', table_path, storage_destination
    ])
    print(output)


def set_project(project):
    output, _ = exec_shell_command([
        'gcloud', 'config', 'set', 'project', project
    ])
    print(output)


def import_csv(storage_source, database_instance, table_name, database_name, user_name):
    output, _ = exec_shell_command([
        'gcloud', 'sql', 'import', 'csv',
        database_instance,
        storage_source,
        '--database', database_name,
        '--table', table_name,
        '--user', user_name,
        '--quiet'
    ])
    print(output)

def import_sql(storage_source, database_instance, database_name, user_name):
    output, _ = exec_shell_command([
        'gcloud', 'sql', 'import', 'sql',
        database_instance,
        storage_source,
        '--database', database_name,
        '--user', user_name,
        '--quiet'
    ])
    print(output)


def delete_storage_object(storage_path):
    _ = exec_shell_command([
        'gsutil', 'rm', storage_path
    ])
    print(f"Deleted object in", storage_path)
