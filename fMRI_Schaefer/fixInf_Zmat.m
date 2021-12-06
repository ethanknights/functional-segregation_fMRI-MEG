function [outD] = fixInf_Zmat(Zmat)

MaxZ = max(Zmat(isfinite(Zmat)));
Zmat(find(Zmat==Inf)) = MaxZ;

MinZ = min(Zmat(isfinite(Zmat)));
Zmat(find(Zmat==-Inf)) = MinZ;

outD = Zmat;

end