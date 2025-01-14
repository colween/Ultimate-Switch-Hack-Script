::Script by Shadow256
call tools\storage\functions\ini_scripts.bat
Setlocal enabledelayedexpansion
set this_script_full_path=%~0
set associed_language_script=%language_path%\!this_script_full_path:%ushs_base_path%=!
set associed_language_script=%ushs_base_path%%associed_language_script%
IF NOT EXIST "%associed_language_script%" (
	set associed_language_script=languages\FR_fr\!this_script_full_path:%ushs_base_path%=!
	set associed_language_script=%ushs_base_path%!associed_language_script!
	echo The associated language file cannot be found, please run the updater to download it. French will be set as default.
	pause
)
IF NOT EXIST "%associed_language_script%" (
	echo Language error. Please use the update manager to update the script. This script will now close.
	pause
	endlocal
	goto:eof
)
IF EXIST "%~0.version" (
	set /p this_script_version=<"%~0.version"
) else (
	set this_script_version=1.00.00
)
:define_action_choice
call "%associed_language_script%" "display_title"
set action_choice=
cls
call "%associed_language_script%" "display_menu"
IF "%action_choice%"=="1" goto:biskey_dump
IF "%action_choice%"=="2" goto:mariko_partial_keys_decrypt
IF "%action_choice%"=="3" goto:hid-mitm_compagnon
IF "%action_choice%"=="4" goto:emuguiibo
IF "%action_choice%"=="5" goto:game_saves_unpack
IF "%action_choice%"=="6" goto:launch_linux
IF "%action_choice%"=="7" goto:update_shofel2
goto:end_script
:biskey_dump
set action_choice=
echo.
cls
IF EXIST "tools\Storage\biskey_dump.bat" (
	call tools\Storage\update_manager.bat "update_biskey_dump.bat"
) else (
	call tools\Storage\update_manager.bat "update_biskey_dump.bat" "force"
)
call TOOLS\Storage\biskey_dump.bat
@echo off
goto:define_action_choice
:mariko_partial_keys_decrypt
set action_choice=
echo.
cls
IF EXIST "tools\Storage\partial_aes_mariko_keys_decrypt.bat" (
	call tools\Storage\update_manager.bat "update_partial_aes_mariko_keys_decrypt.bat"
) else (
	call tools\Storage\update_manager.bat "update_partial_aes_mariko_keys_decrypt.bat" "force"
)
call TOOLS\Storage\partial_aes_mariko_keys_decrypt.bat
@echo off
goto:define_action_choice
:hid-mitm_compagnon
set action_choice=
echo.
cls
IF EXIST "tools\Storage\launch_hid-mitm_compagnon.bat" (
	call tools\Storage\update_manager.bat "update_launch_hid-mitm_compagnon.bat"
) else (
	call tools\Storage\update_manager.bat "update_launch_hid-mitm_compagnon.bat" "force"
)
call tools\Storage\launch_hid-mitm_compagnon.bat
@echo off
goto:define_action_choice
:emuguiibo
set action_choice=
echo.
cls
IF EXIST "tools\Storage\launch_emuGUIibo.bat" (
	call tools\Storage\update_manager.bat "update_launch_emuGUIibo.bat"
) else (
	call tools\Storage\update_manager.bat "update_launch_emuGUIibo.bat" "force"
)
call tools\Storage\launch_emuGUIibo.bat
@echo off
goto:define_action_choice
:game_saves_unpack
set action_choice=
echo.
cls
IF EXIST "tools\Storage\game_saves_unpack.bat" (
	call tools\Storage\update_manager.bat "update_game_saves_unpack.bat"
) else (
	call tools\Storage\update_manager.bat "update_game_saves_unpack.bat" "force"
)
call tools\Storage\game_saves_unpack.bat
@echo off
goto:define_action_choice
:launch_linux
set action_choice=
echo.
cls
IF EXIST "tools\Storage\launch_linux.bat" (
	call tools\Storage\update_manager.bat "update_launch_linux.bat"
) else (
	call tools\Storage\update_manager.bat "update_launch_linux.bat" "force"
)
call TOOLS\Storage\launch_linux.bat
@echo off
goto:define_action_choice
:update_shofel2
set action_choice=
echo.
cls
IF EXIST "tools\Storage\update_shofel2.bat" (
	call tools\Storage\update_manager.bat "update_update_shofel2.bat"
) else (
	call tools\Storage\update_manager.bat "update_update_shofel2.bat" "force"
)
call TOOLS\Storage\update_shofel2.bat
@echo off
goto:define_action_choice
:end_script
endlocal