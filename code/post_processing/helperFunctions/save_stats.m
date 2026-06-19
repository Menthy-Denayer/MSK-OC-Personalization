function struct = save_stats(struct, name, pList, dzList, deltaList, stdList)
    name = strrep(name," ", "_");
    struct.(name).p = pList;
    struct.(name).dz = dzList;
    struct.(name).delta = deltaList;
    struct.(name).std = stdList;
end