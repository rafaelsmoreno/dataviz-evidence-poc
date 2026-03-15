BEGIN { OFS=","; print "year,value" }
{
    n = split($0, records, "},")
    for (i = 1; i <= n; i++) {
        r = records[i]
        year = ""
        val_str = ""
        ds = index(r, "\"date\":\"")
        if (ds > 0) year = substr(r, ds + 8, 4)
        vs = index(r, "\"value\":")
        if (vs > 0) {
            val_str = substr(r, vs + 8)
            sub(/[,} \t\n].*/, "", val_str)
            if (val_str != "null" && val_str != "" && year != "") {
                print year, val_str
            }
        }
    }
}
