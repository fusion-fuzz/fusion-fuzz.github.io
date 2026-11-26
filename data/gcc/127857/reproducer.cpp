	  for (off = 0; off < line.length(); ++off)
	    if (line[off] != ' ' && line[off] != '\t')
	      break;
	  if (off > 0)
	    {
	      obstack_1grow (&buf_obstack, ' ');
	      line = line.subspan (off, line.length() - off);
	    }
