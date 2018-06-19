import psycopg2
import psycopg2.extras

from mysite import settings 

class DbHelper:

	@staticmethod
	def _open_conn():
		conn_str = settings.PGSQL_CONN_STR
		conn = psycopg2.connect( \
			dsn = conn_str, \
			cursor_factory = psycopg2.extras.DictCursor)
		return conn

	@staticmethod
	def _close_conn(conn):
		if conn is not None:
			conn.close()

	@staticmethod
	def run_query_sp(spname, params):
		conn = None
		try:
			conn = DbHelper._open_conn()
			cur = conn.cursor()
			cur.callproc(spname, params)
			result = DbHelper._cursor_as_object_list(cur)
			return result
		except (psycopg2.Error, Exception) as error:
			print(error)
			raise
		finally:
			DbHelper._close_conn(conn)
	
	@staticmethod
	def _cursor_as_object_list(cur):
		result = []
		data = cur.fetchall()
		desc = cur.description
		for row in data:
			obj = {}
			for i in range(0, len(desc)):
				column = desc[i]
				obj[column.name] = row[i]
			result.append(obj)
		return result