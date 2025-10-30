import re

namefile = open('names.txt')

for line in open('terraform.tfvars'):
	if line.startswith('  {'):
		line = re.sub('---', namefile.readline().strip(), line)
	print(line, end='')
