function [sourceP]=nw_procrustes_applytr(cfg, source)
%Convience function to apply linear transformation to align data from a
%"source"-participant to a "target"-space (transformation information
%calculated e.g. using nw_procrustes_calctr.m). 
%
%Input:
%       cfg.tr = transformation data structure obtained using Matlab
%                  procrustes function (used e.g. within nw_procrustes_calctr.m)
%       cfg.inverse = if intention is to re-transform data (e.g. data
%           aligned to subject X now re-aligned to subject Y; would require tr 
%           structure from subject Y to X)
%       source = timelock-or preproc data i.e. must contain avg- or trial-field
%
%Output:
%       - sourceP = The Procustes transformed data structure
%
%See also nw_procrustes_calctr.m
%
%Jan 2020: First Implementation NW

if isempty(cfg.tr)
    error('Function requires tr-structure')
end

tr=cfg.tr;
cfg.inverse = ft_getopt(cfg, 'inverse', false, 1);

sourceP=source;
if ~istrue(cfg.inverse)
    if isfield(source, 'avg')
        sourceP.avg = (tr.b * (source.avg)' * tr.T + repmat(tr.c,[size((source.avg)',1),1]))';
    elseif isfield(source, 'trial')
        for ii= 1:length(source.trial)
            sourceP.trial{ii} = (tr.b * (source.trial{ii})' * tr.T + repmat(tr.c,[size((source.trial{ii})',1),1]))';
        end %for
    else
        error('Function requires timelock or preproc data')
    end %if
elseif istrue(cfg.inverse) %EXPERIMENTAL
    if isfield(source, 'avg')
        sourceP.avg = (inv(tr.b) * (source.avg'-repmat(tr.c,[size((source.avg)',1),1])) * inv(tr.T))'; %#ok<MINV>
    elseif isfield(source, 'trial')
        for ii= 1:length(source.trial)
            sourceP.trial{ii} = (inv(tr.b) * (source.trial{ii}'-repmat(tr.c,[size((source.trial{ii})',1),1])) * inv(tr.T))'; %#ok<MINV>
        end %for
    else
        error('Function requires timelock or preproc data')
    end %if     
end
