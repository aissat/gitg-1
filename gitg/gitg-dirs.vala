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

namespace Gitg
{

public class Dirs
{
	public static string data_dir
	{
		get { return Config.GITG_DATADIR; }
	}

	public static string locale_dir
	{
		get { return Config.GITG_LOCALEDIR; }
	}

	public static string lib_dir
	{
		get { return Config.GITG_LIBDIR; }
	}

	public static string plugins_dir
	{
		owned get { return Path.build_filename(lib_dir, "plugins"); }
	}

	public static string plugins_data_dir
	{
		owned get { return Path.build_filename(data_dir, "plugins"); }
	}

	public static string user_plugins_dir
	{
		owned get { return Path.build_filename(Environment.get_user_data_dir(), "gitg", "plugins"); }
	}

	public static string user_plugins_data_dir
	{
		owned get { return user_plugins_dir; }
	}

	public static string build_data_file(string part, ...)
	{
		var l = va_list();
		var ret = Path.build_filename(data_dir, part, null);

		while (true)
		{
			string? s = l.arg();

			if (s == null)
			{
				break;
			}

			ret = Path.build_filename(ret, s);
		}

		return ret;
	}
}

}

// ex: ts=4 noet
