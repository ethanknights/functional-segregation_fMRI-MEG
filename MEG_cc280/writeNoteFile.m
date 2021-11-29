function writeNoteFile(subDir,noteStr)

tmp = datestr(datetime);

fileID = fopen(fullfile(subDir,[noteStr,'.txt']),'w');
fmt = '%s';
fprintf(fileID,fmt, tmp);
fclose(fileID);

fprintf('%s\n%s\n',subDir,noteStr);
end