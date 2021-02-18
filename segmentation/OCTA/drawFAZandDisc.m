function [] = drawFAZandDisc(fileName, fileFolder, eyeSide)
[center_faz, final_faz] = segmentFazOCTA(fileName, fileFolder);
[center_disk, final_disk] = foveaToDiskOCTA(fileName, fileFolder, eyeSide);
x_disk = center_disk(1);
y_disk = center_disk(2);
x_faz = center_faz(1);
y_faz = center_faz(2);

figure, imshow(final_faz);
figure, imshow(final_disk);

C = final_faz;
C = insertShape(C, 'Line', [x_disk y_disk x_faz y_faz],'LineWidth',3,'Color','green');
C = insertShape(C, 'FilledCircle', [x_faz, y_faz, 5], 'Color', 'green');
C = insertShape(C, 'FilledCircle', [x_disk, y_disk, 5], 'Color', 'green');
figure, imshow(C);

end
