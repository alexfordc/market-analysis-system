# Utility functions for making releases

import os
from sys import *
from __builtin__ import open
from string import *
from PackageMaker import PackageMaker

config_file = 'release_config'

class ReleaseUtilities:

	def __init__(self, libdir):
		self.true = 1
		self.false = 0
		self.Archive_index = 0
		self.File_index = 1
		self.Source_index = 0
		self.Target_index = 1
		self.work_dir_word = "work_directory"
		self.source_dir_word = "source_directory"
		self.package_word = "package"
		self.target_dir_word = "target_directory"
		self.relname_word = "release_name"
		self.source_files = []
		self.target_files = []
		self.source_directory = ''
		self.work_directory = ''
		# packages is a hash table - key: package name; value:
		# [[archive types], [list of all target files in a package]]
		self.packages = {}
		self.keyword_table = {self.source_dir_word: self.set_source,
						self.work_dir_word: self.set_work,
						self.package_word: self.add_package,
						self.relname_word: self.set_release_name,
						self.target_dir_word: self.set_target_dir}
		# Read configuration file and set up source directory,
		# work directory, ...
		if not (libdir == ''):
			config_file_path = libdir + '/' + config_file
		else:
			config_file_path = config_file
		file = open(config_file_path)
		for line in file.readlines():
			record = split(line)
			key = record[0]
			value = record[1]
			args = []
			for i in range(2, len(record)):
				if record[i][0] == '#': break
				args.append(record[i])
			if self.keyword_table.has_key(key):
				self.keyword_table[key](value, args)
		file.close()
		if self.source_directory == '' or self.work_directory == '':
			raise "Source or work directory not set."
		else:
			self.packager = PackageMaker(self.work_directory,
				self.target_dir)

	def check_settings(self):
		error = self.false
		if len(self.source_directory) == 0:
			print 'Error: source_directory not set'
			error = self.true
		if len(self.work_directory) == 0:
			print 'Error: work_directory not set'
			error = self.true
		if error:
			print 'Exiting ...'
			sys.exit(-1)

	# Add `f' to the source file list.
	def add_source_file(self, f):
		self.source_files.append(f)

	# Add `f' to the target file list.
	def add_target_file(self, f):
		self.target_files.append(f)

	# Add (`src_path', `tgt_path') to each package identified by `keys'.
	def add_to_packages(self, src_path, tgt_path, keys):
		for k in keys:
			if not self.packages.has_key(k):
				print "Warning: No package " + k + " found."
			else:
				# The 2nd list ([1]) is the list of src/tgt paths.
				self.packages[k][self.File_index].append((src_path, tgt_path))

	# For each p in `packages', create package p and place all
	# files defined for p into p.
	def make_packages(self):
		for k in self.packages.keys():
			self.copy(self.packages[k])
			self.packager.execute(k, self.packages[k])
			self.cleanup()

# Private - implementation

	# Copy source files to target files.
	def copy(self, package):
		dos_str = "[dos]"; dslen = len(dos_str)
		self.make_work_dir()
		file_tuples = package[self.File_index]
		os.chdir(self.source_directory)
		for i in range(len(file_tuples)):
			dos_cnv = 0
			tgtpath = file_tuples[i][self.Target_index]
			srcpath = file_tuples[i][self.Source_index]
			if tgtpath[len(tgtpath) - dslen:] == dos_str:
				dos_cnv = 1
				tgtpath = tgtpath[:-dslen]
			self.do_copy(srcpath, tgtpath, dos_cnv)
		self.clean_work()

	# Remove work directory.
	def cleanup(self):
		self.system_execute('rm -rf ' + self.real_work_directory)

	# Set the source directory to `s'.
	def set_source(self, s, args):
		self.source_directory = s

	# Set the work directory to `s'.
	def set_work(self, s, args):
		self.work_directory = s

	# Set the work directory to `s'.
	def set_release_name(self, s, args):
		self.real_work_directory = self.work_directory
		self.work_directory = self.work_directory + '/' + s

	# Add the package `s' to `packages'.
	def add_package(self, s, args):
		self.packages[s] = [args, []]

	# Set the target directory to `s'.
	def set_target_dir(self, s, args):
		self.target_dir = s

	# Clean garbage (such as CVS directories) from work directory.
	def clean_work(self):
		self.system_execute("find " + self.work_directory +
			" -name CVS -exec rm -rf {} \; 2>/dev/null")
		self.system_execute("find " + self.work_directory +
			" -type d -perm 000 -exec rmdir {} ';' 2>/dev/null")

	def do_copy(self, srcpath, tgtpath, dos_convert):
		cmd = ''; doscnvrt_cmd = 'unix2dos'
		if tgtpath == '.':
			cmd = 'cp -fRr --parents ' + srcpath + ' ' + self.work_directory
		else:
			work_dir = ''
			if os.path.isdir(srcpath):
				work_dir = self.work_directory + '/' + tgtpath
				cmd = 'cp -fRr ' + srcpath + ' ' + work_dir
			elif os.path.isfile(self.strip_char(srcpath, "\\")):
				work_dir = self.work_directory + '/' + \
					os.path.dirname(tgtpath)
				cmd = 'cp -f ' + srcpath + ' ' + self.work_directory + \
					'/' + tgtpath
				if dos_convert:
					cmd = cmd + '; cd $(dirname ' + self.work_directory + \
						'/' + tgtpath + '); ' + doscnvrt_cmd + \
						' $(basename ' + tgtpath + ')'
			else:
				print srcpath + ' is not a file or directory - skipping ...'
			# If the work directory doesn't exist yet, make it:
			if not os.path.isdir(work_dir):
				cmd = 'mkdir -p ' + work_dir + '; ' + cmd
		self.system_execute(cmd, 1)

	# Make the work directory if it doesn't yet exist.
	def make_work_dir(self):
		if not os.path.exists(self.work_directory):
			self.system_execute('mkdir -p ' + self.work_directory, 1);

	# Strip all occurrences of `c' from `s'.
	def strip_char(self, s, c):
		return join(split(s, c), '')

	# Execute 'cmd'
	def system_execute(self, s, abort_on_failure = 0):
		sysresult = os.system(s)
		if abort_on_failure and sysresult != 0:
			print "System command '" + s + "' failed with value %d ", sysresult
			print "Aborting ..."
			exit(sysresult)
