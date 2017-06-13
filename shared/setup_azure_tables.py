from collections import defaultdict
from itertools import zip_longest
from uuid import uuid4

from azure.storage.table import TableBatch
from azure.storage.table import TableService


def _grouper(iterable, n, fillvalue=None):
    groups = [iter(iterable)] * n
    return zip_longest(*groups, fillvalue=fillvalue)


def _setup_tables(account_name, account_key, table_name, batch_size=100, max_num=1000000):
    table_service = TableService(account_name, account_key)
    table_service.create_table(table_name)

    partitions = defaultdict(list)
    for num in range(1, max_num + 1):
        partitions[('%03d' % num)[:3]].append(str(num))

    for partition, nums in partitions.items():
        for batch_num, batch in enumerate(_grouper(nums, batch_size), start=1):
            table_batch = TableBatch()
            for num in filter(None, batch):
                table_batch.insert_entity({
                    'PartitionKey': partition,
                    'RowKey': num,
                    'value': str(uuid4()),
                })
            table_service.commit_batch(table_name, table_batch)
            print('Done with partition %s, batch %d' % (partition, batch_num))


if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser(__doc__)
    parser.add_argument('--account', required=True)
    parser.add_argument('--key', required=True)
    parser.add_argument('--table', default='pythonloadtests')
    args = parser.parse_args()

    _setup_tables(args.account, args.key, args.table)
