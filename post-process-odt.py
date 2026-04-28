import zipfile
import sys
import os
import re

RUBY_STYLE_DEF = '''    <style:style style:name="Ru1" style:family="ruby">
      <style:ruby-properties style:ruby-align="center" style:ruby-position="above" loext:ruby-position="above"/>
    </style:style>'''

def add_ruby_style(odt_path):
    tmp_path = odt_path + '.tmp'
    with zipfile.ZipFile(odt_path, 'r') as zin:
        with zipfile.ZipFile(tmp_path, 'w', zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                data = zin.read(item.filename)
                if item.filename == 'content.xml':
                    xml = data.decode('utf-8')
                    if 'style:name="Ru1"' not in xml:
                        xml = xml.replace(
                            '<office:automatic-styles>',
                            '<office:automatic-styles>\n' + RUBY_STYLE_DEF
                        )
                    data = xml.encode('utf-8')
                zout.writestr(item, data)
    os.replace(tmp_path, odt_path)
    print("  [post-process] Ru1 ruby style added to ODT")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 post-process-odt.py <file.odt>")
        sys.exit(1)
    add_ruby_style(sys.argv[1])
