function [w,v] = freesurfer_read_wfile(fname)

% freesurfer_read_wfile - FreeSurfer I/O function to read an overlay (*.w) file
%
% [w,vert] = freesurfer_read_wfile(fname)
%
% reads a vector from a binary 'w' file
%    fname - name of file to read from
%    w     - vector of values
%   vert  - vertex indices
%
% After reading an associated surface, with freesurfer_read_surf, try:
% patch('vertices',vert,'faces',face,...
%       'facecolor','interp','edgecolor','none',...
%       'FaceVertexCData',w); light
%
% See also freesurfer_write_wfile, freesurfer_read_surf, freesurfer_read_curv

if (nargin ~= 1),
    msg = sprintf('USAGE: [w,v] = freesurfer_read_wfile(fname)\n');
    error(msg);
end

% open it as a big-endian file
fid = fopen(fname, 'rb', 'b') ;
if (fid < 0),
    str = sprintf('could not open w file %s.', fname) ;
    error(str) ;
end

fread(fid, 1, 'int16');  % Skip latency int

vnum = freesurfer_fread3(fid) ;  % Number of non-zero values
v = zeros(vnum,1) ;
w = zeros(vnum,1) ;
for i=1:vnum,
    v(i) = freesurfer_fread3(fid) ;
    w(i) = fread(fid, 1, 'float') ;
end

fclose(fid) ;

if nargout > 1,
%     fprintf('...adding 1 to vertex indices for matlab compatibility.\n');
    v = v + 1;
end

% w = zeros(max(v),1);
% w(v+1) = w0;

return