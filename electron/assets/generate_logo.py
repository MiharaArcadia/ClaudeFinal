"""
Carby Pixel-Art Crab Logo Generator v2
512x512 RGBA — rote Krabbe mit Apfel (links) und Pommes (rechts)
"""
from PIL import Image, ImageDraw
import os, shutil

T  = (0,0,0,0)
R  = (204,34,0,255)   # crab body
RH = (255,90,50,255)  # highlight
RS = (140,18,0,255)   # shadow
RD = (90,8,0,255)     # deep
OR = (255,160,0,255)  # orange belly dots
AP = (210,30,30,255)  # apple body
AH = (255,100,80,255) # apple shine
AL = (40,140,40,255)  # leaf
AS = (90,45,10,255)   # stalk
FC = (190,20,20,255)  # fries container
FW = (210,40,40,255)  # fries container highlight
FP = (255,210,20,255) # fries
FH = (255,240,140,255)# fries tip
EW = (255,255,255,255)
EP = (15,10,5,255)
ER = (180,20,0,255)
SK = (220,50,10,255)  # eye stalk
MB = (40,8,0,255)     # mouth

W = 64
img = Image.new('RGBA', (W, W), T)
d = ImageDraw.Draw(img)

def px(x,y,c):
    if 0<=x<W and 0<=y<W: d.point((x,y),fill=c)
def row(y,x0,x1,c):
    for x in range(x0,x1+1): px(x,y,c)
def col(x,y0,y1,c):
    for y in range(y0,y1+1): px(x,y,c)
def box(x0,y0,x1,y1,c):
    for y in range(y0,y1+1): row(y,x0,x1,c)

# ── BODY ────────────────────────────────────────────────────
box(18,32,45,46,R)
box(16,34,47,44,R)
box(15,36,48,42,R)
# highlights top
box(19,32,34,35,RH)
# shadow bottom
box(18,44,45,46,RS)

# ── HEAD ───────────────────────────────────────────────────
box(20,22,43,32,R)
box(18,24,45,31,R)
box(19,22,38,26,RH)
# head–body join
box(18,30,45,33,R)

# ── EYE STALKS ─────────────────────────────────────────────
box(19,14,22,23,SK); box(19,15,21,22,RH)
box(41,14,44,23,SK); box(42,15,44,22,RH)

# ── LEFT EYE ───────────────────────────────────────────────
# rim
box(13,8,22,17,ER)
# white
box(14,9,21,16,EW)
# pupil (round-ish)
box(16,10,20,15,EP)
row(11,15,21,EW); row(16,9,20,EW)  # carve round top/bottom of white
# shine
px(15,10,EW); px(15,11,EW); px(16,10,EW)

# ── RIGHT EYE ──────────────────────────────────────────────
box(41,8,50,17,ER)
box(42,9,49,16,EW)
box(43,10,48,15,EP)
row(11,42,49,EW); row(16,43,49,EW)
px(43,10,EW); px(43,11,EW); px(44,10,EW)

# ── SMILE (curves upward) ──────────────────────────────────
# bottom arc
for x in range(24,40): px(x,38,MB)
px(23,37,MB); px(23,36,MB)
px(39,37,MB); px(40,37,MB)
px(22,35,MB); px(41,35,MB)
# teeth gap hint
px(31,38,R); px(32,38,R)

# belly dots
px(28,40,OR); px(29,40,OR)
px(34,40,OR); px(35,40,OR)

# ── LEFT ARM / CLAW ────────────────────────────────────────
box(9,26,17,30,R)
box(7,28,16,32,R)
box(9,27,16,29,RH)
# pincer
box(4,20,13,26,R); box(4,21,12,25,RH)
box(4,26,11,31,RS)
# pincer gap
row(27,5,11,T)

# ── RIGHT ARM / CLAW ───────────────────────────────────────
box(46,26,54,30,R)
box(47,28,56,32,R)
box(47,27,54,29,RH)
# pincer
box(50,20,59,26,R); box(51,21,59,25,RH)
box(52,26,59,31,RS)
row(27,52,58,T)

# ── LEGS ────────────────────────────────────────────────────
# left 3
box(13,40,17,42,R); box(12,43,16,45,R); box(11,46,15,48,R)
box(14,42,17,44,RS); box(13,45,16,47,RS); box(12,48,15,50,RS)
# right 3
box(46,40,50,42,R); box(47,43,51,45,R); box(48,46,52,48,R)
box(46,42,49,44,RS); box(47,45,50,47,RS); box(48,48,51,50,RS)

# ── APPLE (left claw, top-left area) ───────────────────────
# body
box(1,8,10,19,AP)
box(0,10,11,17,AP)
# highlight
box(2,9,5,13,AH)
# shadow right
col(10,10,18,RS)
# stalk
col(5,5,7,AS); col(6,5,7,AS)
# leaf (right of stalk)
box(6,4,10,7,AL)
row(5,7,10,AL)

# ── FRENCH FRIES (right claw, top-right area) ──────────────
# container body
box(53,12,63,22,FC)
box(52,13,62,21,FW)
# container highlight stripe
col(53,13,21,FW)
# fry sticks (6 sticks poking up)
fry_xs = [53,55,57,59,61,63]
for xf in fry_xs:
    col(xf,5,12,FP)
    col(xf+1,5,12,FP) if xf<63 else None
    px(xf,5,FH); px(xf,6,FH)

# ── UPSCALE ─────────────────────────────────────────────────
final = img.resize((512,512), Image.NEAREST)
base = os.path.dirname(os.path.abspath(__file__))

logo  = os.path.join(base,'logo.png')
ipng  = os.path.join(base,'icon.png')
iico  = os.path.join(base,'icon.ico')

final.save(logo)
shutil.copy(logo, ipng)

sizes=[16,24,32,48,64,128,256]
icons=[final.resize((s,s),Image.LANCZOS) for s in sizes]
icons[0].save(iico,format='ICO',sizes=[(s,s)for s in sizes],append_images=icons[1:])

for f in [logo,ipng,iico]:
    print(f"{os.path.basename(f):12} {os.path.getsize(f):>8,} bytes")
print("Done!")
