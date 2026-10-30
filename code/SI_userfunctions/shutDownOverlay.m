function shutDownOverlay(src, evt, vargin)
    if evalin('base','exist("hOverlay","var")')

        evalin('base','delete(hOverlay);');   % remove markers + listener
        evalin('base','clear hOverlay');      % remove variable

        disp('hOverlay deleted and cleared from base workspace.');

    else
        disp('hOverlay not found in base workspace.');
    end
end
