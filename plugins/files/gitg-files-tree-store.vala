/*
 * This file is part of gitg
 *
 * Copyright (C) 2012 - Jesse van den Kieboom
 *
 * gitg is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * gitg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gitg. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GitgFiles
{

public class TreeStore : Gtk.TreeStore
{
	private Ggit.Tree d_tree;

	public Ggit.Tree? tree
	{
		get { return d_tree; }
		set
		{
			d_tree = value;
			update();
		}
	}

	construct
	{
		set_column_types(new Type[] {typeof(string), typeof(bool), typeof(Ggit.OId)});

		set_sort_func(0, (model, a, b) => {
			string aname;
			string bname;
			bool aisdir;
			bool bisdir;

			model.get(a, 0, out aname, 1, out aisdir);
			model.get(b, 0, out bname, 1, out bisdir);

			if (aisdir == bisdir)
			{
				return strcmp(aname.collate_key_for_filename(),
				              bname.collate_key_for_filename());
			}
			else if (aisdir)
			{
				return -1;
			}
			else
			{
				return 1;
			}
		});

		set_sort_column_id(0, Gtk.SortType.ASCENDING);
	}

	public Ggit.OId get_id(Gtk.TreeIter iter)
	{
		Ggit.OId ret;

		get(iter, 2, out ret);

		return ret;
	}

	public string get_full_path(Gtk.TreeIter iter)
	{
		string ret = get_name(iter);
		Gtk.TreeIter parent;

		while (iter_parent(out parent, iter))
		{
			ret = Path.build_filename(get_name(parent), ret);
			iter = parent;
		}

		return ret;
	}

	public string get_name(Gtk.TreeIter iter)
	{
		string ret;

		get(iter, 0, out ret);

		return ret;
	}

	public bool get_isdir(Gtk.TreeIter iter)
	{
		bool ret;

		get(iter, 1, out ret);

		return ret;
	}

	private void update()
	{
		clear();

		if (d_tree == null)
		{
			return;
		}

		var paths = new HashTable<string, Gtk.TreePath>(str_hash, str_equal);

		try
		{
			d_tree.walk((root, entry) => {
				var attr = entry.get_attributes();
				var isdir = Posix.S_ISDIR(attr);

				Gtk.TreeIter? parent = null;

				if (root != "")
				{
					get_iter(out parent, paths.lookup(root));
				}

				Gtk.TreeIter iter;
				append(out iter, parent);
				set(iter,
				    0, entry.get_name(),
				    1, isdir,
				    2, entry.get_id());

				if (isdir)
				{
					string path;

					if (root == "")
					{
						path = entry.get_name() + Path.DIR_SEPARATOR_S;
					}
					else
					{
						path = root + entry.get_name() + Path.DIR_SEPARATOR_S;
					}

					paths.insert(path, get_path(iter));
				}

				return 0;
			}, Ggit.TreeWalkMode.POST);
		} catch (Error e) { }
	}
}

}

// vi:ts=4