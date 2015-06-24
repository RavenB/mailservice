"""
Converts the specified CSV file to XLS using xlwt.


Copyright 2012 Kevin Richardson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
"""
import csv
import re
import sys
import os

from dateutil.parser import parse
from datetime import datetime

import xlwt

workbook = xlwt.Workbook()

def csv_to_xls(csv_filename, output=None):
    if output is None:
        output = sys.stdout
    
    int_re = re.compile(r'^\d+$')
    float_re = re.compile(r'^\d+\.\d+$')
    date_re = re.compile(r'^\d+-\d+-\d+$')
    datetime_re = re.compile(r'^(\d+-\d+-\d+)T(\d+:\d+:\d+)\+\d+:\d+$')
    style = xlwt.XFStyle()

    with open(csv_filename, 'rb') as csv_file:
        sheet = workbook.add_sheet(os.path.basename(csv_filename).split('_')[0])

        reader = csv.reader(csv_file)
        row_num = 0
        for row in reader:
            column_num = 0
            for item in row:
                format = 'general'
                if re.match(date_re, item):
                    format = 'M/D/YY'
                elif re.match(datetime_re, item):
                    item = parse(item).replace(tzinfo = None)
                    format = 'dd.mm.yyyy hh:mm'
                elif re.match(float_re, item):
                    item = float(item)
                    format = '0.00'
                elif re.match(int_re, item):
                    item = float(item)
                    format = '0'
                style.num_format_str = format
                sheet.write(row_num, column_num, item, style)
                column_num += 1
            row_num += 1

        first_col = sheet.col(0)
        first_col.width = 256 * 20
        workbook.save(output)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print 'Usage: csv2xls.py input.csv [output.xls]'
        sys.exit(0)
    
    output = sys.argv[-1]
        
    for csvfile in sys.argv[1:-1]:
        print csvfile
        csv_to_xls(csvfile, output)
