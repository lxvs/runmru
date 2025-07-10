#!/usr/bin/env python

__version__ = '0.2.0'

import re
import sys
import winreg
import argparse

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument(
        '-l',
        '--list',
        action='store_true',
    )
    p.add_argument(
        '-i',
        '--delete-by-index',
    )
    p.add_argument(
        '-s',
        '--delete-by-simple-match',
    )
    p.add_argument(
        '-r',
        '--delete-by-regex',
    )
    p.add_argument(
        '-f',
        '--force',
        action='store_true',
        help="dry run if not specified",
    )
    return p.parse_args()

def get_mru(k, l):
    d = {}
    for x in l:
        try:
            d[x] = winreg.QueryValueEx(k, x)[0][:-2]
        except FileNotFoundError:
            pass
    return d

def list_mru(d):
    for k in d.keys():
        print(f"{k}: {d[k]}")

def delete_by_index(k, i, d, f):
    missing = ''
    tbd = ''
    for x in i:
        if x not in d and x not in missing:
            missing += x
        if x not in tbd:
            tbd += x
    if missing:
        print(f"error: invalid index: {missing}", file=sys.stderr)
        return
    if not tbd:
        print("delete_by_index: no match")
        return
    for x in tbd:
        if f:
            winreg.DeleteValue(k, x)
        else:
            print(f"[i] {x}: {d[x]}")

def delete_by_simple_match(k, p, d, f):
    ps = p.split()
    tbd = ''
    for x in d.keys():
        for p in ps:
            if p not in d[x]:
                break
        else:
            if x not in tbd:
                tbd += x
    if not tbd:
        print("delete_by_simple_match: no match")
        return
    for x in tbd:
        if f:
            winreg.DeleteValue(k, x)
        else:
            print(f"[s] {x}: {d[x]}")

def delete_by_regex(k, r, d, f):
    rr = re.compile(r)
    tbd = ''
    for x in d.keys():
        if rr.search(d[x]) and x not in tbd:
            tbd += x
    if not tbd:
        print("delete_by_regex: no match")
        return
    for x in tbd:
        if f:
            winreg.DeleteValue(k, x)
        else:
            print(f"[r] {x}: {d[x]}")

def main():
    a = parse_args()
    al = a.list
    ai = a.delete_by_index
    asm = a.delete_by_simple_match
    ar = a.delete_by_regex
    f = a.force
    k = winreg.OpenKey(winreg.HKEY_CURRENT_USER, 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RunMRU', access=winreg.KEY_READ | winreg.KEY_WRITE)
    l = winreg.QueryValueEx(k, 'MRUList')[0]
    d = get_mru(k, l)
    if al or not (ai or asm or ar):
        list_mru(d)
    if ai:
        delete_by_index(k, ai, d, f)
    if asm:
        delete_by_simple_match(k, asm, d, f)
    if ar:
        delete_by_regex(k, ar, d, f)

if __name__ == '__main__':
    main()
