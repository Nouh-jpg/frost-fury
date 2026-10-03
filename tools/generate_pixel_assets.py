import os
from PIL import Image, ImageDraw

os.makedirs("assets/sprites/hero", exist_ok=True)
os.makedirs("assets/sprites/enemies", exist_ok=True)
os.makedirs("assets/sprites/snowball", exist_ok=True)
os.makedirs("assets/sprites/items", exist_ok=True)
os.makedirs("assets/sprites/tiles", exist_ok=True)
os.makedirs("assets/ui/touch", exist_ok=True)

# 1. GENERATE HERO SPRITESHEET (32x32 per frame, 8 frames wide, 4 rows high)
# Rows:
# Row 0: Idle (4 frames) + Hurt (2 frames) + Jump (2 frames)
# Row 1: Walk / Run (6 frames)
# Row 2: Combo Attack 1 (Jab), Combo Attack 2 (Hook), Combo Attack 3 (Rising Upper)
# Row 3: Blitz Rush (4 frames) + Kick (4 frames)
frame_w, frame_h = 32, 32
hero_img = Image.new("RGBA", (frame_w * 8, frame_h * 4), (0, 0, 0, 0))
d = ImageDraw.Draw(hero_img)

# Palettes
C_ARMOR_DARK = (27, 38, 59, 255)
C_ARMOR_MID  = (65, 90, 119, 255)
C_ARMOR_LGT  = (119, 141, 169, 255)
C_ICE_CYAN   = (0, 245, 255, 255)
C_ICE_WHITE  = (224, 251, 252, 255)
C_SKIN       = (255, 205, 178, 255)
C_GOLD       = (255, 183, 3, 255)

def draw_knight_frame(d, fx, fy, pose="idle", subframe=0):
    ox = fx * frame_w
    oy = fy * frame_h
    
    # Simple retro silhouette layout
    # Head / Helmet
    head_y = oy + 6 + (1 if subframe % 2 == 1 and pose == "walk" else 0)
    
    # Helmet & visor
    d.rectangle([ox + 12, head_y, ox + 19, head_y + 7], fill=C_ARMOR_MID, outline=C_ARMOR_DARK)
    d.line([ox + 13, head_y - 2, ox + 18, head_y - 1], fill=C_ICE_CYAN) # Horn crest
    d.point([ox + 14, head_y + 3], fill=C_ICE_CYAN) # Eye visor
    d.point([ox + 17, head_y + 3], fill=C_ICE_CYAN)
    
    # Cape
    d.rectangle([ox + 9, head_y + 8, ox + 12, head_y + 19], fill=(20, 40, 80, 255))
    
    # Torso Armor
    d.rectangle([ox + 12, head_y + 8, ox + 19, head_y + 16], fill=C_ARMOR_MID, outline=C_ARMOR_DARK)
    d.rectangle([ox + 14, head_y + 10, ox + 17, head_y + 13], fill=C_ARMOR_LGT)
    d.point([ox + 15, head_y + 11], fill=C_ICE_CYAN) # Core gem
    
    # Legs
    leg_y = head_y + 17
    if pose == "idle":
        d.rectangle([ox + 12, leg_y, ox + 14, leg_y + 7], fill=C_ARMOR_DARK)
        d.rectangle([ox + 17, leg_y, ox + 19, leg_y + 7], fill=C_ARMOR_DARK)
        d.rectangle([ox + 11, leg_y + 6, ox + 14, leg_y + 7], fill=C_ARMOR_MID)
        d.rectangle([ox + 17, leg_y + 6, ox + 20, leg_y + 7], fill=C_ARMOR_MID)
    elif pose == "walk":
        offset = [(-2, 2), (-1, 1), (0, 0), (2, -2), (1, -1), (0, 0)][subframe % 6]
        d.rectangle([ox + 12 + offset[0], leg_y, ox + 14 + offset[0], leg_y + 7], fill=C_ARMOR_DARK)
        d.rectangle([ox + 17 + offset[1], leg_y, ox + 19 + offset[1], leg_y + 7], fill=C_ARMOR_DARK)
    elif pose == "jump":
        d.rectangle([ox + 11, leg_y - 1, ox + 14, leg_y + 4], fill=C_ARMOR_DARK)
        d.rectangle([ox + 17, leg_y - 2, ox + 20, leg_y + 3], fill=C_ARMOR_DARK)
    elif pose == "kick":
        d.rectangle([ox + 11, leg_y, ox + 14, leg_y + 7], fill=C_ARMOR_DARK)
        # Extended kicking leg
        d.rectangle([ox + 17, leg_y - 2, ox + 27, leg_y + 2], fill=C_ARMOR_MID, outline=C_ARMOR_DARK)
        d.rectangle([ox + 25, leg_y - 3, ox + 28, leg_y + 3], fill=C_ICE_CYAN) # Frost boot impact
    elif pose == "hurt":
        d.rectangle([ox + 10, leg_y, ox + 13, leg_y + 7], fill=C_ARMOR_DARK)
        d.rectangle([ox + 15, leg_y + 1, ox + 18, leg_y + 6], fill=C_ARMOR_DARK)

    # Arms / Weapon / Combat Hands
    arm_y = head_y + 8
    if pose == "idle":
        d.rectangle([ox + 19, arm_y + 2, ox + 22, arm_y + 7], fill=C_ARMOR_LGT)
        d.rectangle([ox + 10, arm_y + 2, ox + 12, arm_y + 6], fill=C_ARMOR_DARK)
    elif pose == "attack1": # Jab
        d.rectangle([ox + 19, arm_y, ox + 27, arm_y + 4], fill=C_ARMOR_LGT, outline=C_ARMOR_DARK)
        d.rectangle([ox + 26, arm_y - 1, ox + 29, arm_y + 5], fill=C_ICE_CYAN) # Frost fist
    elif pose == "attack2": # Cross Hook
        d.rectangle([ox + 18, arm_y + 1, ox + 28, arm_y + 5], fill=C_ARMOR_LGT, outline=C_ARMOR_DARK)
        d.rectangle([ox + 27, arm_y - 2, ox + 31, arm_y + 6], fill=C_ICE_WHITE)
    elif pose == "attack3": # Rising Upper
        d.rectangle([ox + 18, arm_y - 6, ox + 22, arm_y + 5], fill=C_ARMOR_LGT, outline=C_ARMOR_DARK)
        d.polygon([(ox + 19, arm_y - 7), (ox + 23, arm_y - 12), (ox + 27, arm_y - 4)], fill=C_ICE_CYAN) # Ice geyser
    elif pose == "blitz": # Rush Blitz
        d.rectangle([ox + 20, arm_y - 2, ox + 30, arm_y + 4], fill=C_ICE_CYAN, outline=C_ICE_WHITE)
        d.polygon([(ox + 30, arm_y - 3), (ox + 32, arm_y + 1), (ox + 30, arm_y + 5)], fill=C_ICE_WHITE)
    elif pose == "hurt":
        d.rectangle([ox + 8, arm_y + 1, ox + 11, arm_y + 7], fill=C_ARMOR_DARK)

# Draw row 0: Idle (4), Hurt (2), Jump (2)
for i in range(4):
    draw_knight_frame(d, i, 0, "idle", i)
draw_knight_frame(d, 4, 0, "hurt", 0)
draw_knight_frame(d, 5, 0, "hurt", 1)
draw_knight_frame(d, 6, 0, "jump", 0)
draw_knight_frame(d, 7, 0, "jump", 1)

# Draw row 1: Walk (6 frames)
for i in range(6):
    draw_knight_frame(d, i, 1, "walk", i)

# Draw row 2: Attack 1 (2), Attack 2 (2), Attack 3 (3)
draw_knight_frame(d, 0, 2, "attack1", 0)
draw_knight_frame(d, 1, 2, "attack1", 1)
draw_knight_frame(d, 2, 2, "attack2", 0)
draw_knight_frame(d, 3, 2, "attack2", 1)
draw_knight_frame(d, 4, 2, "attack3", 0)
draw_knight_frame(d, 5, 2, "attack3", 1)
draw_knight_frame(d, 6, 2, "attack3", 2)

# Draw row 3: Blitz (3), Kick (3)
for i in range(3):
    draw_knight_frame(d, i, 3, "blitz", i)
for i in range(3):
    draw_knight_frame(d, 3 + i, 3, "kick", i)

hero_img.save("assets/sprites/hero/hero_sheet.png")

# 2. GENERATE ENEMY GOBLIN BRAWLER SPRITESHEET (32x32 per frame, 8 frames wide, 3 rows high)
# Row 0: Idle (4), Walk (4)
# Row 1: Attack (3), Hurt (2), Freeze Stage 1 (1), Freeze Stage 2 (1), Fully Frozen (1)
enemy_img = Image.new("RGBA", (frame_w * 8, frame_h * 3), (0, 0, 0, 0))
ed = ImageDraw.Draw(enemy_img)

C_GOBLIN_BODY = (178, 58, 34, 255)
C_GOBLIN_DARK = (80, 20, 15, 255)
C_GOBLIN_EYE  = (255, 220, 0, 255)
C_GOBLIN_PANT = (60, 45, 30, 255)

def draw_enemy_frame(ed, fx, fy, pose="idle", subframe=0, frozen_lvl=0):
    ox = fx * frame_w
    oy = fy * frame_h
    head_y = oy + 9 + (1 if subframe % 2 == 1 and pose == "walk" else 0)
    
    # Horns
    ed.polygon([(ox + 12, head_y), (ox + 10, head_y - 4), (ox + 13, head_y - 1)], fill=(40, 30, 25, 255))
    ed.polygon([(ox + 19, head_y), (ox + 21, head_y - 4), (ox + 18, head_y - 1)], fill=(40, 30, 25, 255))
    
    # Head
    ed.rectangle([ox + 11, head_y, ox + 20, head_y + 7], fill=C_GOBLIN_BODY, outline=C_GOBLIN_DARK)
    # Eyes
    ed.point([ox + 13, head_y + 3], fill=C_GOBLIN_EYE)
    ed.point([ox + 17, head_y + 3], fill=C_GOBLIN_EYE)
    
    # Body
    ed.rectangle([ox + 11, head_y + 7, ox + 20, head_y + 14], fill=C_GOBLIN_BODY, outline=C_GOBLIN_DARK)
    
    # Legs
    leg_y = head_y + 14
    if pose == "idle":
        ed.rectangle([ox + 11, leg_y, ox + 14, leg_y + 7], fill=C_GOBLIN_PANT)
        ed.rectangle([ox + 17, leg_y, ox + 20, leg_y + 7], fill=C_GOBLIN_PANT)
    elif pose == "walk":
        offset = [(-1, 1), (1, -1), (-1, 1), (1, -1)][subframe % 4]
        ed.rectangle([ox + 11 + offset[0], leg_y, ox + 14 + offset[0], leg_y + 7], fill=C_GOBLIN_PANT)
        ed.rectangle([ox + 17 + offset[1], leg_y, ox + 20 + offset[1], leg_y + 7], fill=C_GOBLIN_PANT)
    elif pose == "attack":
        ed.rectangle([ox + 11, leg_y, ox + 14, leg_y + 7], fill=C_GOBLIN_PANT)
        ed.rectangle([ox + 18, leg_y, ox + 21, leg_y + 7], fill=C_GOBLIN_PANT)
        # Punching arm
        ed.rectangle([ox + 19, head_y + 7, ox + 28, head_y + 11], fill=C_GOBLIN_BODY, outline=C_GOBLIN_DARK)
    elif pose == "hurt":
        ed.rectangle([ox + 9, leg_y, ox + 12, leg_y + 6], fill=C_GOBLIN_PANT)
        ed.rectangle([ox + 15, leg_y + 1, ox + 18, leg_y + 6], fill=C_GOBLIN_PANT)

    # Frost layer overlay (Snow Bros style freeze progression)
    if frozen_lvl == 1:
        # Frost crystals at bottom
        for px in range(ox + 8, ox + 24, 2):
            ed.point([px, oy + 28 - (px % 3)], fill=C_ICE_CYAN)
            ed.point([px + 1, oy + 27], fill=C_ICE_WHITE)
    elif frozen_lvl == 2:
        # Enveloping frost shell
        ed.ellipse([ox + 7, oy + 12, ox + 25, oy + 30], outline=C_ICE_CYAN)
        for px in range(ox + 9, ox + 23, 3):
            ed.point([px, oy + 20 + (px % 4)], fill=C_ICE_WHITE)
    elif frozen_lvl == 3:
        # Fully encased sphere with trapped enemy silhouette
        ed.ellipse([ox + 4, oy + 4, ox + 28, oy + 28], fill=(0, 180, 216, 180), outline=C_ICE_WHITE)
        ed.ellipse([ox + 6, oy + 6, ox + 26, oy + 26], outline=C_ICE_CYAN)
        ed.point([ox + 10, oy + 8], fill=C_ICE_WHITE)
        ed.point([ox + 11, oy + 8], fill=C_ICE_WHITE)
        ed.point([ox + 10, oy + 9], fill=C_ICE_WHITE)

for i in range(4):
    draw_enemy_frame(ed, i, 0, "idle", i)
for i in range(4):
    draw_enemy_frame(ed, 4 + i, 0, "walk", i)

draw_enemy_frame(ed, 0, 1, "attack", 0)
draw_enemy_frame(ed, 1, 1, "attack", 1)
draw_enemy_frame(ed, 2, 1, "attack", 2)
draw_enemy_frame(ed, 3, 1, "hurt", 0)
draw_enemy_frame(ed, 4, 1, "hurt", 1)
draw_enemy_frame(ed, 5, 1, "idle", 0, frozen_lvl=1) # Chill 1
draw_enemy_frame(ed, 6, 1, "idle", 0, frozen_lvl=2) # Chill 2
draw_enemy_frame(ed, 7, 1, "idle", 0, frozen_lvl=3) # Full sphere

enemy_img.save("assets/sprites/enemies/goblin_sheet.png")

# 3. GENERATE FROST SPHERE SPRITESHEET (Rolling Wrecking Ball, 32x32 per frame, 4 frames)
sphere_img = Image.new("RGBA", (frame_w * 4, frame_h), (0, 0, 0, 0))
sd = ImageDraw.Draw(sphere_img)

for f in range(4):
    ox = f * frame_w
    # Rolling sphere circle
    sd.ellipse([ox + 2, 2, ox + 30, 30], fill=(0, 180, 216, 255), outline=(224, 251, 252, 255))
    sd.ellipse([ox + 4, 4, ox + 28, 28], outline=(144, 224, 239, 255))
    
    # Rotating internal ice crystal / trapped enemy mark
    angle_shift = f * 3
    sd.line([ox + 10 + angle_shift % 10, 12, ox + 22 - angle_shift % 8, 20], fill=(20, 60, 100, 200), width=3)
    # Highlights & sparkles
    sd.point([ox + 8, 8], fill=(255, 255, 255, 255))
    sd.point([ox + 9, 8], fill=(255, 255, 255, 255))
    sd.point([ox + 8, 9], fill=(255, 255, 255, 255))
    sd.point([ox + 22, 24], fill=(255, 255, 255, 220))

sphere_img.save("assets/sprites/snowball/frost_sphere_sheet.png")

# 4. GENERATE ITEMS / PICKUPS (16x16 per item: Red Potion, Speed Boot, Ice Gem, Golden Star)
item_img = Image.new("RGBA", (16 * 4, 16), (0, 0, 0, 0))
itd = ImageDraw.Draw(item_img)

# Item 0: Red Health Potion (Streets of Rage roast chicken / Snow Bros red potion)
itd.rectangle([6, 1, 9, 3], fill=(180, 180, 180, 255)) # Cork
itd.rectangle([4, 4, 11, 14], fill=(217, 4, 41, 255), outline=(100, 0, 15, 255))
itd.point([6, 6], fill=(255, 150, 160, 255)) # Glass highlight

# Item 1: Speed Boots (Snow Bros blue speed potion / golden boots)
ox = 16
itd.polygon([(ox + 3, 11), (ox + 12, 11), (ox + 14, 14), (ox + 2, 14)], fill=(255, 183, 3, 255))
itd.polygon([(ox + 3, 6), (ox + 9, 6), (ox + 9, 11), (ox + 3, 11)], fill=(251, 133, 0, 255))
# Wings
itd.line([ox + 1, 4, ox + 6, 8], fill=(255, 255, 255, 255), width=2)

# Item 2: Ice Gem (Diamond score pickup 1000 pts)
ox = 32
itd.polygon([(ox + 7, 2), (ox + 13, 6), (ox + 7, 14), (ox + 1, 6)], fill=(0, 245, 255, 255), outline=(255, 255, 255, 255))
itd.polygon([(ox + 7, 4), (ox + 10, 6), (ox + 7, 11), (ox + 4, 6)], fill=(224, 251, 252, 255))

# Item 3: Golden Power Star (Special gauge boost)
ox = 48
itd.polygon([(ox + 7, 1), (ox + 9, 6), (ox + 14, 6), (ox + 10, 10), (ox + 12, 15), (ox + 7, 12), (ox + 2, 15), (ox + 4, 10), (ox + 0, 6), (ox + 5, 6)], fill=(255, 215, 0, 255), outline=(200, 150, 0, 255))

item_img.save("assets/sprites/items/pickups.png")

# 5. GENERATE RETRO TILESET (Citadel stone brick & icy platform slabs, 16x16 tiles)
tile_img = Image.new("RGBA", (16 * 4, 16 * 2), (0, 0, 0, 0))
td = ImageDraw.Draw(tile_img)

# Tile 0,0: Stone Floor with Snow
td.rectangle([0, 0, 15, 15], fill=(50, 55, 75, 255))
td.rectangle([0, 0, 15, 3], fill=(224, 251, 252, 255)) # Snow cap
td.line([0, 7, 15, 7], fill=(30, 35, 50, 255)) # Brick mortar
td.line([7, 0, 7, 7], fill=(30, 35, 50, 255))
td.line([0, 15, 15, 15], fill=(30, 35, 50, 255))

# Tile 1,0: Stone Center Brick
td.rectangle([16, 0, 31, 15], fill=(45, 50, 70, 255))
td.line([16, 7, 31, 7], fill=(25, 30, 45, 255))
td.line([23, 0, 23, 7], fill=(25, 30, 45, 255))
td.line([19, 7, 19, 15], fill=(25, 30, 45, 255))

# Tile 2,0: Icy Crystal Platform (One-way jump-through platform)
td.rectangle([32, 0, 47, 5], fill=(0, 180, 216, 255), outline=(224, 251, 252, 255))
td.polygon([(34, 5), (36, 11), (38, 5)], fill=(144, 224, 239, 255)) # Icicle hanging
td.polygon([(41, 5), (43, 9), (45, 5)], fill=(144, 224, 239, 255))

# Tile 3,0: Castle Wall Decorative Arch
td.rectangle([48, 0, 63, 15], fill=(35, 40, 58, 255))
td.line([48, 0, 63, 0], fill=(20, 25, 40, 255))

tile_img.save("assets/sprites/tiles/citadel_tiles.png")

# 6. GENERATE TOUCH SCREEN CONTROLS ICONS (64x64 each for high DPI mobile screens)
def make_touch_button(name, label, color):
    btn = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    bd = ImageDraw.Draw(btn)
    # Circular glowing arcade button
    bd.ellipse([4, 4, 59, 59], fill=(20, 25, 35, 160), outline=color, width=3)
    bd.ellipse([8, 8, 55, 55], outline=(color[0], color[1], color[2], 90), width=1)
    # Simple letter draw
    bd.text((26, 22), label, fill=color)
    btn.save(f"assets/ui/touch/{name}.png")

make_touch_button("btn_attack", "A", (255, 80, 80, 255))   # Red Attack (A)
make_touch_button("btn_jump", "B", (80, 220, 255, 255))    # Cyan Jump (B)
make_touch_button("btn_blitz", "X", (255, 200, 50, 255))   # Yellow Blitz (X)
make_touch_button("btn_special", "Y", (180, 80, 255, 255)) # Purple Special (Y)

# Touch D-Pad base
dpad = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
dd = ImageDraw.Draw(dpad)
dd.ellipse([8, 8, 119, 119], fill=(15, 20, 30, 140), outline=(100, 140, 180, 200), width=3)
# Arrows
dd.polygon([(64, 18), (52, 34), (76, 34)], fill=(180, 210, 240, 220)) # UP
dd.polygon([(64, 110), (52, 94), (76, 94)], fill=(180, 210, 240, 220)) # DOWN
dd.polygon([(18, 64), (34, 52), (34, 76)], fill=(180, 210, 240, 220)) # LEFT
dd.polygon([(110, 64), (94, 52), (94, 76)], fill=(180, 210, 240, 220)) # RIGHT
dpad.save("assets/ui/touch/dpad.png")

print("All pixel assets generated successfully!")
