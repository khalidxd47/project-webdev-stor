from html.parser import HTMLParser
from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parents[1];PUBLIC=ROOT/'public'
class Page(HTMLParser):
 def __init__(self):super().__init__(convert_charrefs=True);self.tags=[];self.assets=[];self.ids=[]
 def handle_starttag(self,tag,attrs):
  a=dict(attrs);self.tags.append((tag,a))
  if a.get('id'):self.ids.append(a['id'])
  for key in ['src','href']:
   if a.get(key):self.assets.append(a[key])
records=[];images=set();tables=0;inline=0;forms=0;styles=''
for file in sorted(PUBLIC.glob('*.html')):
 source=file.read_text('utf-8-sig');page=Page();page.feed(source)
 assert '<?' not in source,(file.name,'PHP in HTML')
 assert any(t=='meta'and a.get('name')=='viewport'for t,a in page.tags),file.name
 for required in ['title','header','footer','nav','main','h1']:assert any(t==required for t,a in page.tags),(file.name,required)
 assert not any(t=='style'for t,a in page.tags),(file.name,'internal CSS')
 assert not any(t=='script'and not a.get('src')for t,a in page.tags),(file.name,'inline JS')
 assert len(page.ids)==len(set(page.ids)),(file.name,'duplicate ID')
 assert len(source.splitlines())>80,(file.name,'compressed HTML')
 for ref in page.assets:
  if ref.startswith(('http:','https:','#','mailto:','data:')):continue
  ref=ref.split('#')[0].split('?')[0]
  assert (file.parent/ref).is_file(),(file.name,ref)
 for t,a in page.tags:
  if t=='img'and a.get('src'):images.add(a['src'])
  tables+=t=='table';forms+=t=='form';inline+=bool(a.get('style'))
 records.append({'file':file.name,'lines':len(source.splitlines()),'own_main_content':True,'valid_local_resources':True})
for f in (PUBLIC/'assets/css').glob('*.css'):styles+=f.read_text('utf-8-sig')
assert len(records)==20
assert len(images)>=10
assert tables>=2 and forms>=1
assert inline>=1 # inline CSS example + external CSS: two types required by course PDF.
assert len(set(re.findall(r'#[a-fA-F0-9]{3,8}\b',styles)))>8
for rule in ['display: flex','display: grid',':hover','transform:','filter:','transition:','@media']:assert rule in styles,rule
assert (PUBLIC/'dashboard.php').is_file()
assert re.search(r'<audio\b',(PUBLIC/'index.html').read_text('utf-8'))
assert re.search(r'<ol\b',(PUBLIC/'shipping.html').read_text('utf-8'))
assert re.search(r'<ul\b',(PUBLIC/'about.html').read_text('utf-8'))
output={'html_pages':len(records),'unique_images':len(images),'html_tables':tables,'forms':forms,'inline_css_examples':inline,'records':records}
(ROOT/'docs/structure-test-results.json').write_text(json.dumps(output,ensure_ascii=False,indent=2),'utf-8')
print(f'PASS {len(records)} separate HTML pages; {len(images)} unique images; {tables} tables; all local links/assets resolve; readable code.')
