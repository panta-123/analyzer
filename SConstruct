#!/usr/bin/env python
###### Hall A Software Main SConstruct Build File #####
###### Author:	Edward Brash (brash@jlab.org) June 2013
###### Modified for Podd 1.7 directory layout: Ole Hansen (ole@jlab.org) Sep 2018

import os
import SCons
import configure
import re
import podd_util

EnsureSConsVersion(2,3,0)

from SCons.Script.SConscript import SConsEnvironment
SConsEnvironment.OSCommand = SCons.Action.ActionFactory(os.system,
            lambda command : 'os.system("%s")' % command)

baseenv = Environment(ENV = os.environ,tools=["default","disttar","symlink","rootcint"],
                      toolpath=['site_scons'])

#baseenv.Append(verbose = 5)

####### Hall A Build Environment #############
baseenv.Append(MAIN_DIR = Dir('.').abspath)
baseenv.Append(HA_DIR = baseenv.subst('$MAIN_DIR'))
baseenv.Append(HA_Podd = baseenv.subst('$HA_DIR')+'/Podd ')
baseenv.Append(HA_HallA = baseenv.subst('$HA_DIR')+'/HallA ')
baseenv.Append(HA_DC = baseenv.subst('$HA_DIR')+'/hana_decode ')
baseenv.Append(MAJORVERSION = '1')
baseenv.Append(MINORVERSION = '7')
baseenv.Append(PATCH = '0')
baseenv.Append(SOVERSION = baseenv.subst('$MAJORVERSION')+'.'+baseenv.subst('$MINORVERSION'))
baseenv.Append(VERSION = baseenv.subst('$SOVERSION')+'.'+baseenv.subst('$PATCH'))
baseenv.Append(NAME = 'analyzer-'+baseenv.subst('$VERSION'))
baseenv.Append(EXTVERS = '-devel')
baseenv.Append(HA_VERSION = baseenv.subst('$VERSION')+baseenv.subst('$EXTVERS'))
#print ("Main Directory = %s" % baseenv.subst('$HA_DIR'))
print ("Software Version = %s" % baseenv.subst('$VERSION'))
ivercode = 65536*int(float(baseenv.subst('$SOVERSION'))) + \
           256*int(10*(float(baseenv.subst('$SOVERSION')) - \
                       int(float(baseenv.subst('$SOVERSION'))))) + \
                       int(float(baseenv.subst('$PATCH')))
baseenv.Append(VERCODE = ivercode)
baseenv.Append(CPPPATH = ['$HA_DIR','$HA_Podd','$HA_DC','$HA_HallA'])
env_analyzer = os.getenv('ANALYZER')
if not env_analyzer:
    env_analyzer = '.'
baseenv.Append(INSTALLDIR = env_analyzer)
print ('Will install in INSTALLDIR = "%s"' % baseenv.subst('$INSTALLDIR'))
baseenv.Alias('install',baseenv.subst('$INSTALLDIR'))
baseenv.Append(RPATH = ['$HA_Podd','$HA_DC','$HA_HallA'])

# Default RPATH handling like CMake's default: always set in build location,
#    delete when installing
# If rpath=1 given, then set installation RPATH to installation libdir
if int(ARGUMENTS.get('rpath',0)):
    baseenv.Replace(ADD_INSTALL_RPATH = '1')
baseenv.AddMethod(podd_util.InstallWithRPATH)
baseenv.AddMethod(podd_util.InstallLibWithRPATH)

configure.FindROOT(baseenv)
configure.FindEVIO(baseenv)

######## Configure Section #######

if not baseenv.GetOption('help'):

   configure.config(baseenv,ARGUMENTS)

   conf = Configure(baseenv)
   if not baseenv.GetOption('clean'):
       if not conf.CheckCXX():
           print('!!! Your compiler and/or environment is not correctly configured.')
           #Exit(1)
           # if not conf.CheckFunc('printf'):
           #         print('!!! Your compiler and/or environment is not correctly configured.')
           #         Exit(1)
   baseenv = conf.Finish()

######## cppcheck ###########################

if baseenv.subst('$CPPCHECK') == '1':
    is_cppcheck = baseenv.WhereIs('cppcheck')
    print ("Path to cppcheck is %s" % is_cppcheck)

    if(is_cppcheck == None):
        print('!!! cppcheck not found on this system.  Check if cppcheck is installed and in your PATH.')
        Exit(1)
    else:
        cppcheck_command = baseenv.Command('cppcheck_report.txt',[],"cppcheck --quiet --enable=all src/ hana_decode/ 2> $TARGET")
        print ("cppcheck_command = %s" % cppcheck_command)
        baseenv.AlwaysBuild(cppcheck_command)

####### build source distribution tarball #############

if baseenv.subst('$SRCDIST') == '1':
    baseenv['DISTTAR_FORMAT']='gz'
    baseenv.Append(
        DISTTAR_EXCLUDEEXTS=['.o','.os','.so','.a','.dll','.cache','.pyc','.cvsignore','.dblite','.log', '.gz', '.bz2', '.zip','.pcm','.supp','.patch','.txt','.dylib']
        , DISTTAR_EXCLUDEDIRS=['.git','VDCsim','bin','scripts','.sconf_temp','tests','work','hana_scaler']
        , DISTTAR_EXCLUDERES=[r'Dict\.cxx$', r'Dict\.h$',r'analyzer',r'\~$',r'\.so\.',r'\.#', r'\.dylib\.']
        )
    tar = baseenv.DistTar("dist/analyzer-"+baseenv.subst('$VERSION'),[baseenv.Dir('#')])
    print ("tarball target = %s" % tar)

Export('baseenv')

###    tar_command = 'tar cvz -C .. -f ../' + baseenv.subst('$NAME') + '.tar.gz -X .exclude -V "JLab/Hall A C++ Analysis Software '+baseenv.subst('$VERSION') + ' `date -I`" ' + '../' + baseenv.subst('$NAME') + '/.exclude ' + '../' + baseenv.subst('$NAME') + '/Changelog ' + '../' + baseenv.subst('$NAME') + '/src ' + '../' + baseenv.subst('$NAME') + '/hana_decode ' + '../' + baseenv.subst('$NAME') + '/Makefile ' + '../' + baseenv.subst('$NAME') + '/*.py' + '../' + baseenv.subst('$NAME') + '/SConstruct'

#print (baseenv.Dump())
#print ('CXXFLAGS = ', baseenv['CXXFLAGS'])
#print ('LINKFLAGS = ', baseenv['LINKFLAGS'])
#print ('SHLINKFLAGS = ', baseenv['SHLINKFLAGS'])

####### Start of main SConstruct ############

baseenv.Append(LIBPATH=['$HA_Podd','$HA_HallA','$HA_DC'])
baseenv.Prepend(LIBS=['HallA','Podd','dc'])

SConscript(dirs = ['Podd', 'HallA', 'hana_decode', 'apps'],name='SConscript.py',exports='baseenv')

if 'uninstall' in COMMAND_LINE_TARGETS:
    baseenv.Command("uninstall-scons-installed-files", None, Delete(FindInstalledFiles()))
    baseenv.Alias("uninstall", "uninstall-scons-installed-files")

#######  End of SConstruct #########

# Local Variables:
# mode: python
# End:
