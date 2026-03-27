import React, { useEffect, useMemo, useState } from 'react';
import { ApiClient, useNotice } from 'adminjs';
import {
  Box,
  Button,
  H2,
  H5,
  Input,
  Label,
  Loader,
  MessageBox,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Text,
  TextArea,
} from '@adminjs/design-system';

const api = new ApiClient();
const PAGE_NAME = 'sql-console';

const SqlConsolePage = () => {
  const sendNotice = useNotice();
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [executing, setExecuting] = useState(false);
  const [result, setResult] = useState(null);
  const [helperText, setHelperText] = useState('');
  const [rowLimit, setRowLimit] = useState('100');

  useEffect(() => {
    let mounted = true;

    const loadInitialState = async () => {
      try {
        const response = await api.getPage({ pageName: PAGE_NAME });
        if (!mounted) {
          return;
        }

        setQuery(response.data.defaultQuery || '');
        setHelperText(response.data.helperText || '');
      } catch (error) {
        if (!mounted) {
          return;
        }

        setResult({
          ok: false,
          error: error?.message || '초기 SQL 콘솔 정보를 불러오지 못했습니다.',
        });
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    };

    loadInitialState();

    return () => {
      mounted = false;
    };
  }, []);

  const displayRows = useMemo(() => {
    if (!result?.rows || !Array.isArray(result.rows)) {
      return [];
    }

    const parsedLimit = Number.parseInt(rowLimit, 10);
    if (Number.isNaN(parsedLimit) || parsedLimit <= 0) {
      return result.rows;
    }

    return result.rows.slice(0, parsedLimit);
  }, [result, rowLimit]);

  const executeQuery = async () => {
    setExecuting(true);

    try {
      const response = await api.getPage({
        pageName: PAGE_NAME,
        method: 'post',
        data: { query },
      });

      setResult(response.data);

      if (response.data.ok) {
        sendNotice({
          message:
            response.data.mode === 'read'
              ? `${response.data.rowCount ?? 0}건을 조회했습니다.`
              : `${response.data.affectedRows ?? 0}건에 반영되었습니다.`,
          type: 'success',
        });
      } else {
        sendNotice({
          message: response.data.error || 'SQL 실행에 실패했습니다.',
          type: 'error',
        });
      }
    } catch (error) {
      const message = error?.message || 'SQL 실행 중 네트워크 오류가 발생했습니다.';
      setResult({ ok: false, error: message });
      sendNotice({ message, type: 'error' });
    } finally {
      setExecuting(false);
    }
  };

  return (
    <Box variant="grey" minHeight="100vh">
      <Box
        bg="white"
        mx="auto"
        my="xl"
        px="xl"
        py="xl"
        width={1}
        maxWidth="1280px"
        boxShadow="card"
        borderRadius="lg"
      >
        <H2 mb="sm">SQL Console</H2>
        <Text mb="lg" color="grey60">
          AdminJS 안에서 직접 MySQL 쿼리를 실행하고 결과를 확인합니다.
        </Text>

        <MessageBox variant="warning" mb="xl">
          단일 SQL 문만 실행할 수 있습니다. SELECT, SHOW, DESC, EXPLAIN 계열은 결과 테이블로,
          그 외 SQL은 영향 건수로 표시됩니다.
        </MessageBox>

        {helperText ? (
          <Text mb="xl" color="grey60">
            {helperText}
          </Text>
        ) : null}

        <Box mb="lg">
          <Label required htmlFor="sql-query">
            SQL Query
          </Label>
          <TextArea
            id="sql-query"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            rows={12}
            width={1}
            fontFamily="monospace"
          />
        </Box>

        <Box display="flex" gap="default" alignItems="flex-end" flexWrap="wrap" mb="xl">
          <Box width={['100%', '180px']}>
            <Label htmlFor="row-limit">Preview Rows</Label>
            <Input
              id="row-limit"
              value={rowLimit}
              onChange={(event) => setRowLimit(event.target.value)}
            />
          </Box>

          <Button variant="primary" onClick={executeQuery} disabled={executing}>
            {executing ? 'Executing...' : 'Execute SQL'}
          </Button>
        </Box>

        {loading ? (
          <Loader />
        ) : null}

        {!loading && result?.ok === false ? (
          <MessageBox variant="danger" mb="xl">
            <H5 mb="sm">Execution Error</H5>
            <Text fontFamily="monospace" whiteSpace="pre-wrap">
              {result.error}
            </Text>
          </MessageBox>
        ) : null}

        {!loading && result?.ok && result.mode === 'mutation' ? (
          <MessageBox variant="success" mb="xl">
            <H5 mb="sm">Execution Result</H5>
            <Text>affectedRows: {String(result.affectedRows ?? 0)}</Text>
          </MessageBox>
        ) : null}

        {!loading && result?.ok && result.mode === 'read' ? (
          <Box>
            <Box display="flex" justifyContent="space-between" alignItems="center" mb="lg" flexWrap="wrap" gap="default">
              <H5 mb="0">Query Result</H5>
              <Text color="grey60">
                total rows: {String(result.rowCount ?? 0)} / showing: {String(displayRows.length)}
              </Text>
            </Box>

            <Box overflowX="auto">
              <Table>
                <TableHead>
                  <TableRow>
                    {(result.columns || []).map((column) => (
                      <TableCell key={column}>{column}</TableCell>
                    ))}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {displayRows.length ? (
                    displayRows.map((row, index) => (
                      <TableRow key={`row-${index}`}>
                        {(result.columns || []).map((column) => (
                          <TableCell key={`${index}-${column}`}>
                            <Text fontFamily="monospace" whiteSpace="pre-wrap">
                              {row?.[column] == null ? 'NULL' : String(row[column])}
                            </Text>
                          </TableCell>
                        ))}
                      </TableRow>
                    ))
                  ) : (
                    <TableRow>
                      <TableCell colSpan={(result.columns || []).length || 1}>
                        <Text color="grey60">조회 결과가 없습니다.</Text>
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </Box>
          </Box>
        ) : null}
      </Box>
    </Box>
  );
};

export default SqlConsolePage;
