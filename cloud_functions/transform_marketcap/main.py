import functions_framework
from bs4 import BeautifulSoup
from flask import Response

def parser(html):
    soup = BeautifulSoup(html, features='html5lib')
    rows = soup.find_all('tr')

    tables_rows = [
        [el.text for el in els] for els in [row.find_all(['p', 'span']) for row in rows[1:]]
    ]

    first_10_rows = [','.join([r[2], r[3], r[4]]) for r in tables_rows[:10]]

    rest_rows = [','.join([r[3], r[4], r[5]]) for r in tables_rows[10:]]

    header = 'name,symbol,price\n'
    csv = header + '\n'.join(first_10_rows + rest_rows)

    return csv

@functions_framework.http
def transform_html_into_csv(request):
    """
      Receives a .html file and extracts marketcap data from it.
      Returns a string representing a CSV
    """
    if (request.method == 'POST'):
        return parser(request.data)
    else:
        return Response(None, 405)
