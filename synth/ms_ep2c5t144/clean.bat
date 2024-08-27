@echo off
rmdir /s /q db
rmdir /s /q greybox_tmp
rmdir /s /q incremental_db
rmdir /s /q output_files
del PLLJ_PLLSPE_INFO.txt
del /s *.qws
del pll1.qip

REM del /s *.bak
REM del /s *.orig
REM del /s *.rej
REM del /s *~
REM rmdir /s /q simulation
REM rmdir /s /q hc_output
REM rmdir /s /q .qsys_edit
REM rmdir /s /q hps_isw_handoff
REM rmdir /s /q sys\.qsys_edit
REM rmdir /s /q sys\vip
REM cd sys
REM for /d %%i in (*_sim) do rmdir /s /q "%%~nxi"
REM cd ..
REM for /d %%i in (*_sim) do rmdir /s /q "%%~nxi"
REM del build_id.v
REM del c5_pin_model_dump.txt
REM del /s *.ppf
REM del /s *.ddb
REM del /s *.csv
REM del /s *.cmp
REM del /s *.sip
REM del /s *.spd
REM del /s *.bsf
REM del /s *.f
REM del /s *.sopcinfo
REM del /s *.xml
REM del /s new_rtl_netlist
REM del /s old_rtl_netlist

pause
