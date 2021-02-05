module publisher

import os

enum ParseStatus {
	start
	linkopen
	link
	comment
}

enum LinkType {
	file
	page
	unknown
	html
	data
	email
	anchor
}

enum LinkState {
	ok
	missing
	error
}

struct ParseResult {
pub mut:
	links []Link
}

struct Link {
	// original string //how link was put in the document
	original_descr string // when we want to replace
	original_link  string
pub mut:
	isexternal  bool
	cat         LinkType
	isimage     bool // means started with !
	description string
	filename    string
	url         string
	site        string
	state       LinkState
	extra       string // e.g. ':size=800x900'
	error_msg   string
}

fn (link Link) original_get() string {
	mut l := '[$link.original_descr]($link.original_link)'
	if link.isimage {
		l = '!$l'
	}
	return l
}

// return how to represent link on server
fn (link Link) server_get() string {
	if link.cat == LinkType.page {
		return '[$link.description](page__${link.site}__${link.filename}.md)'
	}
	if link.cat == LinkType.file {
		if link.isimage {
			return '![$link.description](file__${link.site}__$link.filename)'
		} else {
			return '[$link.description](file__${link.site}__${link.filename}.md)'
		}
	}
	return link.original_get()
}

// return how to represent link on source
fn (link Link) source_get(sitename string) string {
	if link.cat == LinkType.page {
		if sitename == link.site {
			return '[$link.description]($link.filename)'
		} else {
			return '[$link.description]($link.site:$link.filename)'
		}
	}
	if link.cat == LinkType.file {
		mut filename := ''

		if link.site == sitename && link.isimage {
			filename = 'img/$link.filename'
		}

		mut j := ''
		if sitename == link.site {
			if link.extra == '' {
				j = '[$link.description]($filename)'
			} else {
				j = '[$link.description]($filename $link.extra)'
			}
		} else {
			if link.extra == '' {
				j = '[$link.description]($link.site:$link.filename)'
			} else {
				j = '[$link.description]($link.site:$link.filename $link.extra)'
			}
		}
		if link.isimage {
			j = '!$j'
		}
		return j
	}
	return link.original_get()
}

// replace original link content in text with $replacewith
fn (link Link) replace(text string, replacewith string) string {
	return text.replace(link.original_get(), replacewith)
}

fn (mut link Link) init() {
	// see if its an external link or internal
	// mut linkstate := LinkState.init
	if link.original_link.contains('://') {
		// linkstate = LinkState.ok
		link.isexternal = true
	}

	if link.original_link.trim(' ').starts_with('#') {
		link.cat = LinkType.anchor
		return
	}

	if link.original_link.trim(' ').starts_with('http') {
		link.cat = LinkType.html
		return
	}
	// deal with special cases where file is not the only thing in ()
	if link.original_link.contains(' ') {
		// to support something like
		//![](./img/license_threefoldfzc.png ':size=800x900')
		splitted := link.original_link.split(' ')
		link.filename = splitted[0]
		link.extra = splitted[1]
	} else {
		link.filename = link.original_link
	}

	if link.original_link.starts_with('mailto:') {
		link.cat = LinkType.email
		return
	}

	if link.filename != '' {
		// lets now check if there is site info in there
		if ':' in link.filename {
			splitted2 := link.filename.split(':')
			if splitted2.len == 2 {
				link.site = name_fix(splitted2[0])
				link.filename = splitted2[1]
			} else {
				panic('link can only have 1 x :')
			}
		}

		link.filename = link.filename.replace('\\', '/')
		link.filename = name_fix(os.base(link.filename)).to_lower().trim('.')

		// check which link type
		ext := os.file_ext(link.filename).trim('.')

		// if link.filename.ends_with("}"){
		// 	println(link)
		// 	panic("a")
		// }

		if ext == '' {
			link.cat = LinkType.page
		} else if ext in ['jpg', 'png', 'svg', 'jpeg', 'gif'] {
			link.isimage = true
			link.cat = LinkType.file
		} else if ext == 'md' {
			panic('should not happen')
			// link.cat = LinkType.page
		} else if ext in ['html', 'htm'] {
			link.cat = LinkType.html
		} else if ext in ['doc', 'docx', 'zip', 'xls', 'pdf', 'xlsx', 'ppt', 'pptx'] {
			link.cat = LinkType.file
		} else if ext in ['json', 'yaml', 'yml', 'toml'] {
			link.cat = LinkType.data
		} else if (!link.original_link.contains_any('./?&;')) && !link.isimage {
			// link.cat = LinkType.page
			panic('need to figure out what to dow with $link.original_link ')
		} else {
			// should be a page if no extension
			// link.cat = LinkType.page
			link.state = LinkState.error
			link.error_msg = "$link.original_link (no match), ext was:'$ext'"
		}
	}
}

fn (mut link Link) check(mut publisher Publisher, mut page Page, linenr int, line string) {
	mut filename_complete := ''
	mut site := &publisher.sites[page.site_id]

	link.description = link.original_descr
	if link.site == '' {
		link.site = site.name
	}
	filename_complete = '$link.site:$link.filename'

	if link.cat in [LinkType.file, LinkType.page] {
		if site.name_change_check(link.filename) {
			// the name of the link changed, will remove .md and will get the alias					
			println("Found link with name to replace: '($link.filename)'")
			link.filename = site.name_fix_alias(link.filename)
		}
	}

	if link.state == LinkState.error {
		page.error_add({
			line: line
			linenr: linenr
			msg: link.error_msg
			cat: PageErrorCat.brokenlink
		}, mut publisher)
		println(link)
		return
	}
	// this can't work, no idea what to do with this, lets see TODO:
	if link.cat == LinkType.html {
		// splitted := link.link.split(" ")
		// mut l := "html__${sitename}__" + splitted[0].replace("/", "__")				
		// if splitted.len > 1{
		// 	l = l + " " + splitted[1 ..].join(" ")
		// }
		return
	}

	if link.cat == LinkType.email {
		return
	}

	if link.cat == LinkType.anchor {
		return
	}

	if link.filename == '' {
		if !link.original_link.trim(' ').starts_with('#') {
			page.error_add({
				line: line
				linenr: linenr
				msg: "EMPTY LINK: for '$link.original_get()'"
				cat: PageErrorCat.brokenlink
			}, mut publisher)
			link.state = LinkState.missing
			return
		}
	}

	if link.cat == LinkType.page {
		if !publisher.page_exists(filename_complete) {
			page.error_add({
				line: line
				linenr: linenr
				msg: "CANNOT FIND PAGE: '$link.filename' for $link.original_get()"
				cat: PageErrorCat.brokenlink
			}, mut publisher)
			link.state = LinkState.missing
			println(link)
			return
		}
		return
	}

	if link.cat == LinkType.file {
		println('filename_complete:$filename_complete')
		if !publisher.file_exists(filename_complete) {
			page.error_add({
				line: line
				linenr: linenr
				msg: "CANNOT FIND FILE: '$link.filename' for $link.original_get()"
				cat: PageErrorCat.brokenlink
			}, mut publisher)
			link.state = LinkState.missing
			println(link)
			return
		}

		mut file := publisher.file_get(filename_complete) or {
			panic('should not be possible because file existed, error:$err')
		}
		// remember in file that this page uses it
		if !(page.id in file.usedby) {
			if page.id == 0 {
				panic('page.id should not be 0')
			}
			file.usedby << page.id
		}

		return
	}
}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// returns all the links
pub fn link_parser(text string) ParseResult {
	mut charprev := ''
	mut char := ''
	mut state := ParseStatus.start
	mut capturegroup_pre := '' // is in the []
	mut capturegroup_post := '' // is in the ()
	mut parseresult := ParseResult{}
	mut isimage := false
	// no need to process files which are not at least 2 chars
	if text.len > 2 {
		charprev = ''
		for i in 0 .. text.len {
			char = text[i..i + 1]
			// check for comments end
			if state == ParseStatus.comment {
				if text[i - 3..i] == '-->' {
					state = ParseStatus.start
					capturegroup_pre = ''
					capturegroup_post = ''
				}
				// check for comments start
			} else if i > 3 && text[i - 4..i] == '<!--' {
				state = ParseStatus.comment
				capturegroup_pre = ''
				capturegroup_post = ''
				// check for end in link or file			
			} else if state == ParseStatus.linkopen {
				// original += char
				if charprev == ']' {
					// end of capture group
					// next char needs to be ( otherwise ignore the capturing
					if char == '(' {
						if state == ParseStatus.linkopen {
							// remove the last 2 chars: ](  not needed in the capturegroup
							state = ParseStatus.link
							capturegroup_pre = capturegroup_pre[0..capturegroup_pre.len - 1]
						} else {
							state = ParseStatus.start
							capturegroup_pre = ''
						}
					} else {
						// cleanup was wrong match, was not file nor link
						state = ParseStatus.start
						capturegroup_pre = ''
					}
				} else {
					capturegroup_pre += char
				}
				// is start, check to find links	
			} else if state == ParseStatus.start {
				if char == '[' {
					if charprev == '!' {
						isimage = true
					}
					state = ParseStatus.linkopen
				}
				// check for the end of the link/file
			} else if state == ParseStatus.link {
				// original += char
				if char == ')' {
					// end of capture group

					parseresult.links << Link{
						original_descr: capturegroup_pre.trim(' ')
						original_link: capturegroup_post.trim(' ')
						isimage: isimage
					}
					capturegroup_pre = ''
					capturegroup_post = ''
					isimage = false
					state = ParseStatus.start
				} else {
					capturegroup_post += char
				}
			}
			charprev = char // remember the previous one
		}
	}
	return parseresult
}
