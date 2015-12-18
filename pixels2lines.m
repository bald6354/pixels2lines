function lines = pixels2lines(skelIm, debug)
%Takes an skeletonized image as an input and extracts lines

if false
    %From Mathworks
    BW = imread('circles.png');
    skelIm = bwmorph(BW,'skel',Inf);
    skelIm(128,:) = 0;
end

%Default debug to false
if ~exist('debug','var')
    debug = '0';
end

%Convert string to number
debug = str2num(debug);

%Init
lines = cell(0,1);

%Group all connected pixels
CC = bwconncomp(skelIm);
S = regionprops(CC,'BoundingBox','Image');

for grpid = 1:numel(S)

    if debug
        clc, grpid
    end
    
    %Get an image from the group
    grpim = S(grpid).Image;

    %Get the offsets to the full image
    offsets = floor(S(grpid).BoundingBox(2:-1:1));

    %while we still have pixels to extract
    while(sum(grpim(:)))

        if debug
            sum(grpim(:))
        end
    
        %Find remanining critical points
        [ep, bp] = vipPixelFinder(grpim);
        targets = cat(1, ep, bp);
        
        if debug
            clf
            imagesc(grpim)
            hold on
            plot(bp(:,2),bp(:,1),'rx')
            plot(ep(:,2),ep(:,1),'go')
        end

        %Check if the image is a single circle
        if isempty(targets)
            [targets(1,1) targets(1,2)] = find(grpim,1);
        end
        
        %Trace from the first endpoint to another endpoint or branchpoint
        line = pixelWalker(grpim, targets(1,:), targets(2:end,:));
        
        if debug
            plot(line(:,2),line(:,1),'k')
            pause(1)
        end
        
        %Remove the selected endpoint to the critical point
        grpim(sub2ind(size(grpim),line(1:end-1,1),line(1:end-1,2))) = 0;
        
        %Remove the last point unless it was a branch point
        if ~(ismember(line(end,:),bp,'rows'))
             grpim(line(end,1),line(end,2)) = 0;
        end
        
        %Save the line
        lines(end+1) = {line+repmat(offsets,size(line,1),1)};
        
        clear bp ep

    end  
end
