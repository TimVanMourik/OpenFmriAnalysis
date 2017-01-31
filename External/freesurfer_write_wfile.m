function freesurfer_write_wfile(fname, w, v)

% freesurfer_write_wfile - FreeSurfer I/O function to write an overlay (*.w) file
%
% [w] = freesurfer_write_wfile(fname, w)
% writes a vector into a binary 'w' file
%  fname - name of file to write to
%  w     - vector of values to be written,
%          assumed sorted from vertex 1:N
%
% See also freesurfer_read_wfile, freesurfer_write_surf, freesurfer_write_curv

if nargin < 3
    v = 1:length(w);
end

% open it as a big-endian file
fid = fopen(fname, 'wb', 'b') ;

vnum = length(w) ;

fwrite(fid, 0, 'int16') ; % latency integer
freesurfer_fwrite3(fid, vnum) ;   % number of vertices
for i = 1:length(v)
  freesurfer_fwrite3(fid, v(i) - 1) ;  % FS vertices start at zero
  fwrite(fid, w(i), 'float') ;
end

fclose(fid) ;

return