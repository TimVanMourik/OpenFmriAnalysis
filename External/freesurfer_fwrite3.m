function freesurfer_fwrite3(fid, val)

% freesurfer_fwrite3 - FreeSurfer function to write a 3 byte integer to a file
%
% freesurfer_fwrite3(fid, val)
%
% see also freesurfer_read3, freesurfer_read_surf, freesurfer_write_surf

if(nargin ~= 2)
  fprintf('USAGE: freesurfer_fwrite3(fid, val)\n');
  return;
end

%fwrite(fid, val, '3*uchar') ;
b1 = bitand(bitshift(val, -16), 255) ;
b2 = bitand(bitshift(val, -8), 255) ;
b3 = bitand(val, 255) ; 
fwrite(fid, b1, 'uchar') ;
fwrite(fid, b2, 'uchar') ;
fwrite(fid, b3, 'uchar') ;

return