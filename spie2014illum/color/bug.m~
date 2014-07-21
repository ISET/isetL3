
close all;clear all;clc

s_initISET
load sceneBug
% That is the original camera load call
% load ../data/L3camera_CMY1_D65.mat;
% camera = modifyCamera(camera,3);

% Without this line, the bug doesn't happen
vcAddObject(scene); sceneWindow;
  
% This doesn't work
[srgbResult, srgbIdeal, raw, camera] = cameraComputesrgb(camera,scene,100,[],[],1,0);
% This doesn't work either
% [srgbResult, srgbIdeal, raw, camera] = cameraComputesrgb_illum(camera, scene, 100, [], [], 1,0, 'D65');
% This works
% sensorResize = 1;
% camera = cameraCompute(camera,scene,[],sensorResize);

% Bug happens
cameraWindow(camera,'ip'); 

% Error Trace:
% ??? Error using ==> imageShowImage at 44
% Image max 2.23 exceeds data max: 1.80
% 
% 
% Error in ==> vcimageEditsAndButtons at 103
% imageShowImage(vcImage,gam);
% 
% Error in ==> vcimageWindow>vcimageRefresh at 677
% vcimageEditsAndButtons(handles,vci);
% 
% Error in ==> vcimageWindow>vcimageWindow_OpeningFcn at 56
% else vcimageRefresh(hObject, eventdata, handles);
% 
% Error in ==> gui_mainfcn at 221
%     feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});
% 
% Error in ==> vcimageWindow at 46
%     [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
% 
% Error in ==> cameraWindow at 52
%         vcAddObject(obj); fig = vcimageWindow;
% 
% Error in ==> bug at 22
% cameraWindow(camera,'ip');