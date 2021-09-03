function [contours_good] = IsContourGood(contours_raw, min_contour_length)
%ISCONTOURGOOD Checking various factors to remove unrelated contours

contours_good = cell(length(contours_raw), 1);
cnt_good_counter = 1;

for k = 1:length(contours_raw)
    cnt = contours_raw{k};
    
    %check for small contours
    if length(cnt) < min_contour_length
        continue
    else
        %append list of good contours
        contours_good{cnt_good_counter, 1} = cnt;
        cnt_good_counter = cnt_good_counter + 1;
    end
end
%remove empty entries
contours_good = contours_good(~cellfun('isempty',contours_good));
end

