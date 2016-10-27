#!/usr/bin/awk -f
function strtonumbases(str, base, i, len, character, pos, result, negative) {
    base = base + 0
    result = 0
    sub(/^ */, "", str)
    negative = str ~ /^-/ ? -1 : 1
    sub(/^[\-+]/, negative, str)
    if (!base) {
        base = 10
        if (str ~ /^0/) {
            base = 8
        }
        if (str ~ /^0[xX]/) {
            base = 16
        }
    }
    if (base == 16) {
        sub(/^0[xX]/, "", str)
    }
    if (base == 10) {
        return str + 0
    }
    len = length(str)
    for (i = 1; i <= len; i++) {
        character = toupper(substr(str, i, 1))
        pos = index("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", character) - 1
        if (pos != -1 && pos <= base) {
            result = result * base + pos
        }
        else {
            return result
        }
    }
    return result * negative
}

{
print strtonumbases($1, 36)
}

