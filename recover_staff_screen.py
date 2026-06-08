# -*- coding: utf-8 -*-
import re

def recover_string(s):
    if 'Ã' in s:
        try:
            r1 = s.encode('cp1252').decode('utf-8')
            r2 = r1.encode('cp1252').decode('utf-8')
            if any(0x0600 <= ord(c) <= 0x06FF or 0x0750 <= ord(c) <= 0x077F or 0xFB50 <= ord(c) <= 0xFDFF for c in r2):
                return r2
        except Exception:
            pass

    try:
        r1 = s.encode('cp1252').decode('utf-8')
        if any(0x0600 <= ord(c) <= 0x06FF or 0x0750 <= ord(c) <= 0x077F or 0xFB50 <= ord(c) <= 0xFDFF for c in r1):
            return r1
    except Exception:
        pass

    return None

def main():
    filepath = r'c:\Users\tanya\Desktop\SD\lib\screens\staff_screen.dart'
    
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    pattern = r"'(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\""
    
    new_lines = []
    replacements_count = 0
    
    for line_idx, line in enumerate(lines):
        matches = list(re.finditer(pattern, line))
        new_line = line
        for match in reversed(matches):
            lit = match.group(0)
            prefix = line[:match.start()]
            if '//' in prefix:
                continue
                
            val = lit[1:-1]
            quote_type = lit[0]
            
            # Print literal for debugging
            if any(c in val for c in ['Ø', 'Ù', 'Ú', 'Û', 'Ã']):
                rec = recover_string(val)
                print(f"Line {line_idx}: literal={val} -> recovered={rec}")
                if rec and rec != val:
                    escaped_recovered = rec.replace('\n', '\\n').replace('\t', '\\t').replace('$', '\\$')
                    if quote_type == "'":
                        escaped_recovered = escaped_recovered.replace("'", "\\'")
                    elif quote_type == '"':
                        escaped_recovered = escaped_recovered.replace('"', '\\"')
                        
                    new_lit = quote_type + escaped_recovered + quote_type
                    start, end = match.span()
                    new_line = new_line[:start] + new_lit + new_line[end:]
                    replacements_count += 1
                    
        new_lines.append(new_line)
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
        
    print(f"Successfully processed staff_screen.dart. Made {replacements_count} replacements.")

if __name__ == '__main__':
    main()
