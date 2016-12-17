import os
import math
MIN_NOTE = 28
MAX_NOTE = 56
notes = ['C', 'D-', 'D', 'E-', 'E', 'F', 'G-', 'G', 'A-', 'A', 'B-', 'B']
for fname in os.listdir('./sounds'):
  if fname.startswith('39'):
    idx = int(fname.split('-')[2].split('.')[0])
    if idx < MIN_NOTE or idx > MAX_NOTE:
      continue
    noteIdx = (idx - MIN_NOTE) % len(notes)
    note = notes[noteIdx]
    num = int(math.floor((idx - MIN_NOTE) / len(notes))) + 3
    os.rename('./sounds/' + fname, './sounds/' + note + str(num) + '.wav')

