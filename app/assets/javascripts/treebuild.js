buildRequirementsTree = function(requirement_tree) {
    return $('#tree').treeview({
        enableLinks: true,
        data: requirement_tree
    })
};