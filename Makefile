build:
	hugo

serve:
	hugo server

resume_pdf:
	pandoc content/resume/index.md --template=content/resume/template.tex --pdf-engine=xelatex -o index.pdf
