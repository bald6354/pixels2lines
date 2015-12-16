function lines = pixels2lines(skelIm)

%Takes an skeletonized image as an input and extracts lines
lines = cell(0,1);

if false
    %From Mathworks
    BW = imread('circles.png');
    skelIm = bwmorph(BW,'skel',Inf);
    skelIm(128,:) = 0;
end

%Group all connected pixels
CC = bwconncomp(skelIm);

for grpid = 1:numel(CC.PixelIdxList)

    %Make an image from the group
    grpim = zeros(size(skelIm));
    grpim(CC.PixelIdxList{grpid}) = 1;
    
    %while we still have pixels to extract
    while(sum(grpim(:)))
        
        %Find remanining critical points
        [ep(:,1), ep(:,2)] = find(bwmorph(grpim,'endpoints'));
        [bp(:,1), bp(:,2)] = find(bwmorph(grpim,'branchpoints'));
        targets = cat(1, ep, bp);
        
        %Trace from the first endpoint to another endpoint or branchpoint
        line = pixelWalker(grpim, targets(1,:), targets(2:end,:));
        
        plot(line(:,2),line(:,1),'k')
        
        pause(2)
        
        %Remove the selected endpoint to the critical point
        grpim(line(1:end-1,1),line(1:end-1,2)) = 0;
        
        %If the last point in the line was an endpoint it is ok to remove that as well
        if ismember(line(end,:),ep,'rows')
             grpim(line(end,1),line(end,2)) = 0;
        end
        
        %Save the line
        lines(end+1) = {line};
        
        clear bp ep
        
        imagesc(grpim)
        plot(line(:,2),line(:,1),'r')
        xlim([80 205])
        ylim([120 240])
        
    end                
end