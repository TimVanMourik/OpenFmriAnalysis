function currentNode = tvm_addCodeBlock(docRoot, language, argument, comment)

currentNode = docRoot.createElement('code');
if ~iscell(language) && ~iscell(argument) && ~iscell(comment)
    language = {language};
    argument = {argument};
    comment = {comment};
end

for i = 1:length(language)
    languageBlock = docRoot.createElement('language');
    languageBlock.setAttribute('name', language{i});
    
    if ~isempty(comment{i})
        commentBlock = docRoot.createElement('comment');
        commentBlock.setAttribute('name', comment{i});
        languageBlock.appendChild(commentBlock);
    end
    
    argumentBlock = docRoot.createElement('argument');
    argumentBlock.setAttribute('name', argument{i});
    languageBlock.appendChild(argumentBlock);
    
    currentNode.appendChild(languageBlock);
end

end %end function













