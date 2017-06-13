from os import environ

from azure.storage.table import TableService

azure_account_name = environ['AZURE_ACCOUNT_NAME']
azure_account_key = environ['AZURE_ACCOUNT_KEY']
azure_table_name = environ['AZURE_TABLE_NAME']
table = TableService(azure_account_name, azure_account_key)
get_entity = table.get_entity


def fetch_value(ident):
    partition_key = ident[:3]
    row_key = ident
    entity = get_entity(azure_table_name, partition_key, row_key)
    value = entity.get('value')
    return {'value': value}
