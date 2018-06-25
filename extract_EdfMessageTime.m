        function tAll = extract_EdfMessageTime(obj,edfMessage)
           % obj the object that processed in iTrack toolobx
           % edfMessage: a cell contains messages
           % {'Study_display','Study_timer'}, or single message
           % {'Study_display'}
           
            numsubs=size(obj.data(:,1),1);
            
            for s=1:numsubs
                eyeStruct=obj.data{s};              
                
                for i = 1:size(eyeStruct,2)
                    for ims = 1:length(edfMessage)
                       tempaa= find(~cellfun(@isempty,strfind(eyeStruct(i).events.message,edfMessage{ims})));
                       if isempty(tempaa)
                           t(i,ims) = nan;
                       else
                       t(i,ims)=double(eyeStruct(i).events.time(tempaa(1))); % always use the first key press
                       end
                    end
                end
                tAll{s}=t;
            end
        end
