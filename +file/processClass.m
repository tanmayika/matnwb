function [Processed, classprops, inherited] = processClass(name, namespace, pregen)
inherited = {};
branch = [{namespace.getClass(name)} namespace.getRootBranch(name)];
branchNames = cell(size(branch));
TYPEDEF_KEYS = {'neurodata_type_def', 'data_type_def'};
for i = 1:length(branch)
    hasTypeDefs = isKey(branch{i}, TYPEDEF_KEYS);
    branchNames{i} = branch{i}(TYPEDEF_KEYS{hasTypeDefs});
end

isGroup = any(strcmp(branchNames, 'NWBContainer'));
for iAncestor=length(branch):-1:1
    node = branch{iAncestor};
    hasTypeDefs = isKey(node, TYPEDEF_KEYS);
    nodename = node(TYPEDEF_KEYS{hasTypeDefs});
    
    if ~isKey(pregen, nodename)
        if isGroup
            class = file.Group(node);
        else
            class = file.Dataset(node);
        end
        props = class.getProps();
        pregen(nodename) = struct('class', class, 'props', props);
    end
    
    Processed(iAncestor) = pregen(nodename).class;
end
classprops = pregen(name).props;
names = keys(classprops);
for iAncestor=2:length(Processed)
    pname = Processed(iAncestor).type;
    parentPropNames = keys(pregen(pname).props);
    inherited = union(inherited, intersect(names, parentPropNames));
end
end