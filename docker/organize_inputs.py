import argparse


ANN = 'ann'
IP = 'ip'
CTRL = 'ctrl'


def get_pairings(annotation_filepath):
    '''
    Takes a filepath as input.  Parses it and returns
    a list of tuples
    '''
    pair_list = []
    for line in open(annotation_filepath):
        pulldown_fq, input_fq = [x.strip() for x in line.strip().split('\t')]
        pair_list.append((pulldown_fq, input_fq))
    return pair_list


def reorder_lists(all_pulldown_fq, all_input_fq, pair_list):
    new_pulldown_fq = []
    new_input_fq = []
    for pairing in pair_list:
        x,y = pairing
        if (x in all_pulldown_fq) and (y in all_input_fq):
            new_pulldown_fq.append(x)
            new_input_fq.append(y)
    return new_pulldown_fq, new_input_fq


def get_commandline_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-a', required=True, dest=ANN)
    parser.add_argument('-i', required=True, dest=IP, nargs='+')
    parser.add_argument('-c', required=True, dest=CTRL, nargs='+')
    args = parser.parse_args()
    return vars(args)


if __name__ == '__main__':
    arg_dict = get_commandline_args()
    pair_list = get_pairings(arg_dict[ANN])
    pulldown_fq, input_fq = reorder_lists(
        arg_dict[IP],
        arg_dict[CTRL],
        pair_list
    )
    with open('ip_fq.txt', 'w') as fout:
        fout.write('\n'.join(pulldown_fq))

    with open('input_fq.txt', 'w') as fout:
        fout.write('\n'.join(input_fq))

