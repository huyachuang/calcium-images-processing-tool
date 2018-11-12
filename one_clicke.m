function varargout = one_clicke(varargin)
% ONE_CLICKE MATLAB code for one_clicke.fig
%      ONE_CLICKE, by itself, creates a new ONE_CLICKE or raises the existing
%      singleton*.
%
%      H = ONE_CLICKE returns the handle to a new ONE_CLICKE or the handle to
%      the existing singleton*.
%
%      ONE_CLICKE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ONE_CLICKE.M with the given input arguments.
%
%      ONE_CLICKE('Property','Value',...) creates a new ONE_CLICKE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before one_clicke_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to one_clicke_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help one_clicke

% Last Modified by GUIDE v2.5 07-Nov-2018 13:40:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @one_clicke_OpeningFcn, ...
                   'gui_OutputFcn',  @one_clicke_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%**************************************************************************%
function Image_ButtonDownFcn(hObject,eventdata, handles)
global CaSignal
CaSignal = image_buttonDown_fcn(hObject,eventdata, handles, CaSignal);
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before one_clicke is made visible.
function one_clicke_OpeningFcn(hObject, eventdata, handles, varargin)
global CaSignal
% Choose default command line output for one_clicke
handles.output = hObject;
CaSignal.ROIs = {};
CaSignal.ROI_num = 0;
CaSignal.ROI_T_num = 0;
CaSignal.TempROI = {};
CaSignal.ROIDiameter = 12;
CaSignal.SummarizedMask = [];
CaSignal.imagePathName = pwd;
CaSignal.TempXY = [1, 1];
set(handles.ModelPathEdit, 'String', pwd);
set(handles.GlobalModelPathEdit, 'String', pwd);
cd(fileparts(which(mfilename)));
addpath('./utils');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes one_clicke wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = one_clicke_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in ChoseFileButton.
function ChoseFileButton_Callback(hObject, eventdata, handles)


function DataPathEdit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function DataPathEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function ImageShowAxes_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes on button press in ModelChooseButton.
function ModelChooseButton_Callback(hObject, eventdata, handles)
global CaSignal
dataPath = get(handles.ModelPathEdit,'String');
[filename, pathName] = uigetfile(fullfile(dataPath, '*.mat'), 'Load Image File');
if isequal(filename,0)
	return;
end
set(handles.ModelPathEdit,'String', fullfile(pathName, filename));
CaSignal.localFCNModelFilename = filename;
CaSignal.localFCNModelPathName = pathName;
CaSignal.localFCNModel = load(fullfile(CaSignal.modelPathName, CaSignal.modelFilename));
set(handles.DrawROICheckbox, 'Enable', 'on');
set(handles.RegisterROIButton, 'Enable', 'on');
set(handles.LocalFCNRetrainButton, 'Enable', 'on');
set(handles.ChooseGlobalModelButton, 'Enable', 'on');


function ModelPathEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ModelPathEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function SubimageShowAxes_CreateFcn(hObject, eventdata, handles)

function ImageShowAxes_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
global CaSignal
if ~isempty(CaSignal.TempROI) && CaSignal.TempROI{7} > CaSignal.ROI_num
	CaSignal.ROI_num = CaSignal.ROI_num + 1;
	CaSignal.ROI_T_num = CaSignal.ROI_T_num + 1;
	CaSignal.ROIs{CaSignal.ROI_num} = CaSignal.TempROI;
	tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
	y_start = CaSignal.TempROI{1};
	y_end = CaSignal.TempROI{2};
	x_start = CaSignal.TempROI{3};
	x_end = CaSignal.TempROI{4};
	tempRoi = CaSignal.TempROI{5};
	tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
	idx = find(tempMask);
	CaSignal.SummarizedMask(idx) = CaSignal.TempROI{7};
	set(handles.ROINumShowText, 'String', num2str(CaSignal.ROI_T_num));
	se = strel('square',3);
	tempMask = imdilate(tempMask, se);
	tempMask = imdilate(tempMask, se);
	CaSignal.cell_score_mask = and(CaSignal.cell_score_mask, 1 - tempMask);
	CaSignal = update_image_show(handles, CaSignal);
	CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
	sprintf('save ROI %d', CaSignal.ROI_T_num)
end


% --- Executes on key press with focus on SaveButton and none of its controls.
function SaveButton_KeyPressFcn(hObject, eventdata, handles)


% --- Executes on button press in ReDrawButton.
function ReDrawButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal = redraw_fcn(handles, CaSignal);
% CaSignal.TempROI{8} = 'F';
% CaSignal = update_subimage_show(handles, CaSignal);
% roi_idx = CaSignal.TempROI{7};
% y_start = CaSignal.TempROI{1};
% y_end = CaSignal.TempROI{2};
% x_start = CaSignal.TempROI{3};
% x_end = CaSignal.TempROI{4};
% h_draw = imfreehand;
% if numel(h_draw) == 0
% 	return;
% end
% % pos = h_draw.getPosition;
% BW = createMask(h_draw);
% B = bwboundaries(BW, 'noholes');
% boundary = B{1};
% CaSignal.TempROI = {y_start, y_end, x_start, x_end, BW, boundary, CaSignal.TempROI{7}, 'T'};
% 
% if CaSignal.TempROI{7} <= CaSignal.ROI_num
% 	CaSignal.ROIs{CaSignal.TempROI{7}} = CaSignal.TempROI;
% end
% 
% CaSignal = update_subimage_show(handles, CaSignal);



% --- Executes on button press in DeleteButton.
function DeleteButton_Callback(hObject, eventdata, handles)
global CaSignal
if CaSignal.TempROI{7} <= CaSignal.ROI_num && CaSignal.TempROI{8} == 'T'
	sprintf('delete ROI %d', CaSignal.TempROI{7})
	CaSignal.SummarizedMask(CaSignal.SummarizedMask == CaSignal.TempROI{7}) = 0;
	CaSignal.ROI_T_num = CaSignal.ROI_T_num - 1;
	set(handles.ROINumShowText, 'String', num2str(CaSignal.ROI_T_num));
	CaSignal.ROIs{CaSignal.TempROI{7}}{8} = 'F';
	CaSignal.TempROI{8} = 'F';
	CaSignal = update_image_show(handles, CaSignal);
	CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
	CaSignal = update_subimage_show(handles, CaSignal);
end


% --- Executes on button press in FindNextButton.
function FindNextButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal = find_next_fcn(handles, CaSignal);



% --- Executes on button press in MaxMeanBox.
function MaxMeanBox_Callback(hObject, eventdata, handles)
global CaSignal
if get(hObject,'Value') == 1
	CaSignal.showing_image = CaSignal.max_mean_image;
	set(handles.MeanBox,'Value', 0);
	set(handles.MaxBox,'Value', 0);
else
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
	set(handles.MaxBox,'Value', 0);
	set(handles.MaxMeanBox,'Value', 0);
end
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal = update_subimage_show(handles, CaSignal);



% --- Executes on button press in MeanBox.
function MeanBox_Callback(hObject, eventdata, handles)
global CaSignal
if get(hObject,'Value') == 1
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
	set(handles.MaxMeanBox,'Value', 0);
	set(handles.MaxBox,'Value', 0);
else
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
	set(handles.MaxBox,'Value', 0);
	set(handles.MaxMeanBox,'Value', 0);
end
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal = update_subimage_show(handles, CaSignal);


% --- Executes on button press in MaxBox.
function MaxBox_Callback(hObject, eventdata, handles)
global CaSignal
if get(hObject,'Value') == 1
	CaSignal.showing_image = CaSignal.max_images(:, :, CaSignal.current_trial);
	set(handles.MaxMeanBox,'Value', 0);
	set(handles.MeanBox,'Value', 0);
else
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
	set(handles.MaxBox,'Value', 0);
	set(handles.MaxMeanBox,'Value', 0);
end
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal = update_subimage_show(handles, CaSignal);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.top_percentile = get(hObject, 'Value');
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal = update_subimage_show(handles, CaSignal);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.bottom_percentile = get(hObject, 'Value');
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal = update_subimage_show(handles, CaSignal);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function TrialNumEdit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function TrialNumEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NextTrialButton.
function NextTrialButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.current_trial = CaSignal.current_trial + 1;
if CaSignal.current_trial > CaSignal.total_trial
	CaSignal.current_trial = CaSignal.current_trial - CaSignal.total_trial;
end
if get(handles.MaxBox,'Value') == 1
	CaSignal.showing_image = CaSignal.max_images(:, :, CaSignal.current_trial);
elseif get(handles.MeanBox,'Value') == 1
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
end
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal = update_subimage_show(handles, CaSignal);
set(handles.TrialNumEdit, 'String', sprintf('%d/%d', CaSignal.current_trial, CaSignal.total_trial));


% --- Executes on button press in PreviousTrialButton.
function PreviousTrialButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.current_trial = CaSignal.current_trial - 1;
if CaSignal.current_trial < 1
	CaSignal.current_trial = CaSignal.total_trial + CaSignal.current_trial;
end
if get(handles.MaxBox,'Value') == 1
	CaSignal.showing_image = CaSignal.max_images(:, :, CaSignal.current_trial);
elseif get(handles.MeanBox,'Value') == 1
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
end
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal = update_subimage_show(handles, CaSignal);
set(handles.TrialNumEdit, 'String', sprintf('%d/%d', CaSignal.current_trial, CaSignal.total_trial));



function GoToTrialNoEdit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function GoToTrialNoEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GoToButton.
function GoToButton_Callback(hObject, eventdata, handles)
global CaSignal
CaSignal.current_trial = int16(str2num(get(handles.GoToTrialNoEdit, 'String')));
if CaSignal.current_trial > CaSignal.total_trial
	CaSignal.current_trial = CaSignal.current_trial - CaSignal.total_trial;
elseif CaSignal.current_trial < 1
	CaSignal.current_trial = CaSignal.total_trial + CaSignal.current_trial;
end
if get(handles.MaxBox,'Value') == 1
	CaSignal.showing_image = CaSignal.max_images(:, :, CaSignal.current_trial);
elseif get(handles.MeanBox,'Value') == 1
	CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
end
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal = update_subimage_show(handles, CaSignal);
set(handles.TrialNumEdit, 'String', sprintf('%d/%d', CaSignal.current_trial, CaSignal.total_trial));



function GlobalModelPathEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function GlobalModelPathEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ChooseGlobalModelButton.
function ChooseGlobalModelButton_Callback(hObject, eventdata, handles)
global CaSignal
dataPath = get(handles.GlobalModelPathEdit,'String');
[filename, pathName] = uigetfile(fullfile(dataPath, '*.mat'), 'Load FCN model File');
if isequal(filename,0)
	return;
end
set(handles.GlobalModelPathEdit,'String', fullfile(pathName, filename));
CaSignal.global_FCNModel = load(fullfile(pathName, filename));
CaSignal.globalFCNModelFilename = filename;
CaSignal.globalFCNModelPathName = pathName;
CaSignal = global_segmentation(CaSignal);
set(handles.NextROICheckBox,'Enable', 'on');
set(handles.FindNextButton,'Enable', 'on');
set(handles.GlobalFCNRetrainButton,'Enable', 'on');


% --------------------------------------------------------------------
function SaveROIInfoTool_ClickedCallback(hObject, eventdata, handles)
global CaSignal
ROIInfo = {};
n = 0;
for i = 1:CaSignal.ROI_num 
	if CaSignal.ROIs{i}{8} == 'T'
		n = n+1;
		ROIInfo{n} =  CaSignal.ROIs{i};
		ROIInfo{n}{7} = n;
	end
end
if exist(fullfile(CaSignal.imagePathName, 'ROIInfo'), 'dir') == 0
	mkdir(fullfile(CaSignal.imagePathName, 'ROIInfo'));
end
save(fullfile(CaSignal.imagePathName, 'ROIInfo', 'ROIInfo.mat'), 'ROIInfo');


% --------------------------------------------------------------------
function OpenFileTool_ClickedCallback(hObject, eventdata, handles)
global CaSignal
[filename, pathName] = uigetfile(fullfile(CaSignal.imagePathName, '*.tif*'), 'Load Image File');
if isequal(filename,0)
	return;
end
CaSignal.imageFilename = filename;
CaSignal.imagePathName = pathName;
[CaSignal.mean_images, CaSignal.max_images] = load_image_data(CaSignal.imagePathName);
CaSignal.max_mean_image = max(CaSignal.mean_images, [], 3);
CaSignal.imageData = gray2RGB(CaSignal.max_mean_image);
CaSignal.current_trial = 1;
CaSignal.total_trial = size(CaSignal.mean_images, 3);
set(handles.TrialNumEdit, 'String', sprintf('%d/%d', CaSignal.current_trial, CaSignal.total_trial));
CaSignal.showing_image = CaSignal.mean_images(:, :, CaSignal.current_trial);
CaSignal.SummarizedMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
CaSignal.top_percentile = 100.0;
CaSignal.bottom_percentile = 0.0;
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
CaSignal.cell_score = ones(size(CaSignal.max_mean_image));
CaSignal.cell_score_mask = ones(size(CaSignal.max_mean_image));
set(handles.LoadROIButton, 'Enable', 'on');
set(handles.ModelChooseButton, 'Enable', 'on');
set(handles.ModelPathEdit, 'String', CaSignal.imagePathName);
set(handles.GlobalModelPathEdit, 'String', CaSignal.imagePathName);



% --- Executes on button press in DrawROICheckbox.
function DrawROICheckbox_Callback(hObject, eventdata, handles)


% --- Executes on button press in LoadROIButton.
function LoadROIButton_Callback(hObject, eventdata, handles)
global CaSignal
[filename, pathname] = uigetfile(fullfile(CaSignal.imagePathName, '*.mat'), 'Load ROI File');
if isequal(filename,0)
	return;
end
ROIs = load_roi(fullfile(pathname, filename), CaSignal.ROIDiameter);
CaSignal.ROIs = ROIs;
CaSignal.ROI_num = size(CaSignal.ROIs, 2);
CaSignal.ROI_T_num = CaSignal.ROI_num;
CaSignal.TempROI = CaSignal.ROIs{1};
set(handles.ROINumShowText, 'String', num2str(CaSignal.ROI_T_num));
for i = 1:CaSignal.ROI_num
	tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
	y_start = CaSignal.ROIs{i}{1};
	y_end = CaSignal.ROIs{i}{2};
	x_start = CaSignal.ROIs{i}{3};
	x_end = CaSignal.ROIs{i}{4};
	tempRoi = CaSignal.ROIs{i}{5};
	tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
	CaSignal.SummarizedMask(tempMask == 1) = CaSignal.ROIs{i}{7};
end
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};


% --- Executes on button press in RegisterROIButton.
function RegisterROIButton_Callback(hObject, eventdata, handles)
global CaSignal
[filename, pathname] = uigetfile(fullfile(CaSignal.imagePathName, '*.tif*'), 'Load Previous Session Image File');
if isequal(filename,0)
	return;
end
[mean_images, max_images] = load_image_data(pathname);
max_mean_image = max(mean_images, [], 3);
[filename, pathname] = uigetfile(fullfile(pathname, '*.mat'), 'Load Previous Session ROI File');
if isequal(filename,0)
	return;
end
ROIs = load_roi(fullfile(pathname, filename), CaSignal.ROIDiameter);
registered_ROIs = register_roi(ROIs, max_mean_image, CaSignal.max_mean_image, CaSignal);
CaSignal.ROIs = registered_ROIs;
CaSignal.ROI_num = size(CaSignal.ROIs, 2);
CaSignal.ROI_T_num = CaSignal.ROI_num;
CaSignal.TempROI = CaSignal.ROIs{1};
set(handles.ROINumShowText, 'String', num2str(CaSignal.ROI_T_num));
for i = 1:CaSignal.ROI_num
	tempMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
	y_start = CaSignal.ROIs{i}{1};
	y_end = CaSignal.ROIs{i}{2};
	x_start = CaSignal.ROIs{i}{3};
	x_end = CaSignal.ROIs{i}{4};
	tempRoi = CaSignal.ROIs{i}{5};
	tempMask(y_start:y_end, x_start:x_end) = tempRoi(1:y_end - y_start + 1, 1:x_end - x_start + 1);
	CaSignal.SummarizedMask(tempMask == 1) = CaSignal.ROIs{i}{7};
end
CaSignal = update_image_show(handles, CaSignal);
CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
global CaSignal
if strcmp(eventdata.Key, 'space')
	SaveButton_Callback(hObject, eventdata, handles)
elseif strcmp(eventdata.Key, 'd') && CaSignal.TempROI{7} <= CaSignal.ROI_num
	DeleteButton_Callback(hObject, eventdata, handles);
elseif strcmp(eventdata.Key, 'r')
	ReDrawButton_Callback(hObject, eventdata, handles);
elseif strcmp(eventdata.Key, 'n')
	FindNextButton_Callback(hObject, eventdata, handles);
else
	return
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% global CaSignal
% if strcmp(eventdata.Key, 'space')
% 	SaveButton_Callback(hObject, eventdata, handles)
% elseif strcmp(eventdata.Key, 'd') && CaSignal.TempROI{7} <= CaSignal.ROI_num
% 	DeleteButton_Callback(hObject, eventdata, handles);
% elseif strcmp(eventdata.Key, 'r')
% 	ReDrawButton_Callback(hObject, eventdata, handles);
% elseif strcmp(eventdata.Key, 'n')
% 	FindNextButton_Callback(hObject, eventdata, handles);
% else
% 	return
% end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
answer = questdlg('Save ROI information ?', 'Save query');
switch answer
    case 'Yes'
		SaveROIInfoTool_ClickedCallback(hObject, eventdata, handles)
        delete(hObject);
    case 'No'
       delete(hObject);
    case 'Cancel'
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)


% --- Executes on button press in DeleteAllButton.
function DeleteAllButton_Callback(hObject, eventdata, handles)
global CaSignal
answer = questdlg('Do you want to delete all ROI information ?', 'Alert query');
switch answer
    case 'Yes'
		CaSignal.ROIs = {};
		CaSignal.ROI_num = 0;
		CaSignal.ROI_T_num = 0;
		CaSignal.TempROI = {};
		CaSignal.SummarizedMask = zeros(size(CaSignal.imageData, 1), size(CaSignal.imageData, 2));
		CaSignal = update_image_show(handles, CaSignal);
		CaSignal.h_image.ButtonDownFcn = {@Image_ButtonDownFcn, handles};
		CaSignal = update_subimage_show(handles, CaSignal);
    case 'No'
		return
    case 'Cancel'
		return
end


% --- Executes on button press in LocalFCNRetrainButton.
function LocalFCNRetrainButton_Callback(hObject, eventdata, handles)
global CaSignal
datapath = uigetfile_n_dir(CaSignal.imagePathName, 'Chose folders used to train');
if numel(datapath) ~= 0
	CaSignal = retrain_localFCN(CaSignal, datapath);
end


% --- Executes on button press in GlobalFCNRetrainButton.
function GlobalFCNRetrainButton_Callback(hObject, eventdata, handles)
global CaSignal
datapath = uigetfile_n_dir(CaSignal.imagePathName, 'Chose folders used to train');
if numel(datapath) ~= 0
	CaSignal = retrain_globalFCN(CaSignal, datapath);
end


% --- Executes on button press in NextROICheckBox.
function NextROICheckBox_Callback(hObject, eventdata, handles)

